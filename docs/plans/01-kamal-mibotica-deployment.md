# Plan 01 — Migrate production to the mibotica server (Kamal 2)

## Status

Implemented ✅ — production runs on the new server since 2026-09-23.
Cleanup items still open: see [Pending](#pending).

## Goal

Move the ilv-store production app (`tienda.ilvmx.org`) off its dedicated
server and onto the **shared mibotica server**, which already runs
`medistock` and `easy-loans`, with a maintenance window of under an hour.

> **Public repo notice.** This file is committed to a public GitHub repo. It
> must never contain server IPs, local filesystem paths, API keys, passwords,
> or account IDs. Real values live only in the gitignored `.env.production`
> and `config/master.key`. Commands below use shell variables
> (`$SERVER_IP`, `$OLD_SERVER_IP`) that you `export` in your terminal only.

## Architecture

```
Internet
  → Caddy (:80/:443 — owned by medistock's Kamal config)
      mibotica.app               → kamal-proxy :8080 → medistock-web
      prestamos.mibotica.app     → kamal-proxy :8080 → easy_loans-web
      tienda.ilvmx.org           → kamal-proxy :8080 → ilv_store-web
      *.mibotica.app (on-demand) → kamal-proxy :8080 → medistock-web
      storage.mibotica.app       → seaweedfs :8333

ilv_store-web ──(kamal network)──▶ ilv_store-db         postgres:18.6, 127.0.0.1:5436
              ──(kamal network)──▶ ilv_store-typesense  typesense:26.0, 127.0.0.1:8108
              ──(HTTPS egress)───▶ UniOne API · Stripe API · Cloudflare R2 · Sentry
```

- **Caddy** is shared and managed from the **medistock** repo
  (`config/Caddyfile`, named `tienda.ilvmx.org { }` block, standard ACME
  certificate). ilv-store has no Caddy accessory of its own — a second one
  would collide on ports 80/443. Caddy only terminates TLS; it forwards every
  request to kamal-proxy with the original `Host`.
- **kamal-proxy** is a single container shared by every app on the server
  (8080/8443, booted by medistock). It routes by `Host`: each app's
  `kamal deploy` registers its own `proxy.host` on it. **No `proxy.run`
  block, and never run `kamal proxy reboot` from this repo** — that would
  rebind the proxy for every app.
  Inspect the routing table with
  `ssh -p 20202 deploy@$SERVER_IP "docker exec kamal-proxy kamal-proxy list"`.
- **TLS** is terminated by Caddy → `proxy.ssl: false`. `assume_ssl`/`force_ssl`
  stay on (Caddy sends `X-Forwarded-Proto: https`).
- **Postgres** — dedicated accessory, upgraded 16 → 18.6 (same as easy-loans)
  via `pg_dump`/`pg_restore`. Host port **5436** (5432–5435 are already taken
  on this server). Postgres 18 keeps its data under
  `/var/lib/postgresql/18/docker`, so the volume mounts `/var/lib/postgresql`.
- **Typesense** — dedicated accessory. Its data is not migrated: the index is
  rebuilt from Postgres (`bin/rails typesense:recreate`, also run by
  `.kamal/hooks/post-deploy`).
- **UniOne** — HTTP API (`lib/email/providers/uni_one_provider.rb`), sender
  `noreply@ilvmx.org`. The sending domain didn't change → no UniOne changes.
- **Stripe** — live keys and the existing live webhook endpoint
  (`https://tienda.ilvmx.org/webhooks/stripe`); the URL didn't change, it just
  reaches the new server. Events that failed with 503 during maintenance are
  retried by Stripe.
- **Cloudflare R2** — same bucket and origin, no changes.
- **Registry** — Kamal's local registry tunnel (`localhost:5555`), like the
  other apps; Docker Hub is no longer used.
- **SSH** — port 20202, user `deploy` (already set up for the other apps).

## What changed

### This repo

- `config/deploy.yml` — `proxy.ssl: false`, `proxy.host: tienda.ilvmx.org`,
  local registry, `ssh.user: deploy`, `APP_HOST`, `RAILS_LOG_LEVEL: debug`
  removed, `dbc --include-password`, Postgres 18.6 on 5436 with the new data
  mount.
- `.kamal/secrets` — `KAMAL_REGISTRY_PASSWORD` removed.
- `config/environments/production.rb` — mailer `default_url_options`/`asset_host`
  from `APP_HOST` (always `https`); `config.hosts = ['tienda.ilvmx.org']`
  with `/up` excluded.
- `README.md` — deployment section points here.

### medistock repo

- `config/Caddyfile` — named `tienda.ilvmx.org { }` block, proxied to
  `localhost:8080`, applied with `kamal accessory reboot caddy` (restarts TLS
  for every app on the server for a few seconds).

## How the migration was done

1. **Old server into maintenance** — through its kamal-proxy (what
   `kamal app maintenance` runs under the hood):
   ```bash
   ssh -p 20202 root@$OLD_SERVER_IP \
     "docker exec kamal-proxy kamal-proxy stop ilv_store-web --message='Estamos actualizando la tienda. Volvemos en unos minutos.'"
   ```
2. **Dump the primary database** (cache, queue and cable are recreated empty):
   ```bash
   ssh -p 20202 root@$OLD_SERVER_IP \
     "docker exec ilv_store-db pg_dump -U rails -Fc ilv_store_production" > tmp/ilv_store_production.dump
   ```
3. **Boot the accessories and deploy** on the new server:
   ```bash
   dotenv -f .env.production kamal accessory boot all
   dotenv -f .env.production kamal deploy
   ```
   (`kamal setup` does both in one go.)
4. **Restore** into a clean primary DB, then reindex:
   ```bash
   dotenv -f .env.production kamal app stop
   ssh -p 20202 deploy@$SERVER_IP \
     "docker exec ilv_store-db dropdb -U rails ilv_store_production && docker exec ilv_store-db createdb -U rails ilv_store_production"
   ssh -p 20202 deploy@$SERVER_IP \
     "docker exec -i ilv_store-db pg_restore -U rails -d ilv_store_production --no-owner --no-privileges" < tmp/ilv_store_production.dump
   dotenv -f .env.production kamal app boot
   dotenv -f .env.production kamal typesense-reindex
   ```
5. **Caddy** — `tienda.ilvmx.org` block enabled in medistock and
   `kamal accessory reboot caddy`.
6. **DNS** — `tienda.ilvmx.org` A record pointed at the new server (TTL 300).

## Lessons learned

- **`kamal deploy` does not boot accessories.** The first deploy failed its
  health check with `could not translate host name "ilv_store-db"` because the
  db and Typesense containers had never been created. On a fresh server, use
  `kamal setup` (or `kamal accessory boot all` before `kamal deploy`).
- **Lower the DNS TTL *before* the switch.** The record's old TTL was ~3
  hours, so resolvers that had cached it (e.g. an ISP/router resolver) kept
  returning the old IP for up to that long after the change, even though the
  authoritative servers and public resolvers (`1.1.1.1`, `8.8.8.8`) already
  had the new one. Keeping the old server in maintenance covers that gap: late
  visitors see the maintenance page instead of writing to the old database.
  To check propagation, compare the authoritative answer with your local one:
  ```bash
  dig +short tienda.ilvmx.org @$(dig +short NS ilvmx.org | head -1)
  dig +short tienda.ilvmx.org
  ```
- **Check host ports on the shared server first** — the port originally
  planned for Postgres was already in use, hence 5436.

## Day-to-day operations

```bash
dotenv -f .env.production kamal deploy
dotenv -f .env.production kamal logs
dotenv -f .env.production kamal console
dotenv -f .env.production kamal dbc
dotenv -f .env.production kamal typesense-reindex
dotenv -f .env.production kamal accessory details all
```

## Pending

- [ ] Delete `tmp/ilv_store_production.dump` locally (it contains customer data)
- [ ] Keep the old server in maintenance ≥ 48h, confirm it gets no real traffic:
      `ssh -p 20202 root@$OLD_SERVER_IP "docker logs --since 1h kamal-proxy 2>&1 | grep -c tienda.ilvmx.org"`
- [ ] Final dump of the old server, then decommission it
- [ ] Scheduled `pg_dump` backup of `ilv_store-db`, stored off the server
- [ ] Delete the `ilv_store` repository on Docker Hub and its access token
- [ ] Remove `KAMAL_REGISTRY_PASSWORD` from `.env.production`
- [ ] medistock `config/Caddyfile`: the comment above the `tienda.ilvmx.org`
      block still says "To enable: uncomment" — update it
