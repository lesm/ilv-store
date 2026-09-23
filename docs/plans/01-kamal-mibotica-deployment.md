# Plan 01 — Migrate production to the mibotica server (Kamal 2)

## Status

Code ready ✅ — deploy pending (done manually, see [Runbook](#runbook)).

## Goal

Move the ilv-store production app off its current dedicated server and onto
the **shared mibotica server** (the one already running `medistock` and
`easy-loans`):

1. **Pre-stage** (no downtime) — deploy the app on the new server under
   `tienda.mibotica.app` with an empty database, so build, secrets, Caddy,
   TLS, Postgres and Typesense are proven before the migration window.
2. **Migration window** (< 1 hour) — put `tienda.ilvmx.org` in maintenance,
   move the database to the new server, test on `tienda.mibotica.app`, then
   switch the `tienda.ilvmx.org` DNS record to the new server.

`tienda.ilvmx.org` stays the canonical customer-facing domain (Stripe webhook,
email links, SEO). `tienda.mibotica.app` stays as a secondary host.

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
      tienda.mibotica.app        → kamal-proxy :8080 → ilv_store-web   (new)
      tienda.ilvmx.org           → kamal-proxy :8080 → ilv_store-web   (new, after DNS switch)
      *.mibotica.app (on-demand) → kamal-proxy :8080 → medistock-web
      storage.mibotica.app       → seaweedfs :8333

ilv_store-web ──(kamal network)──▶ ilv_store-db         postgres:18.6, 127.0.0.1:5435
              ──(kamal network)──▶ ilv_store-typesense  typesense:26.0, 127.0.0.1:8108
              ──(HTTPS egress)───▶ UniOne API · Stripe API · Cloudflare R2 · Sentry
```

- **Caddy** is shared and managed from the **medistock** repo. ilv-store has
  no Caddy accessory of its own. A named block for `tienda.mibotica.app` is
  **required**: without it, the host falls into medistock's on-demand `:443`
  tenant catch-all and gets routed to medistock.
- **kamal-proxy** is a single container shared by every app on the server
  (8080/8443, booted by medistock). ilv-store only registers its two hosts on
  it — no `proxy.run` block, and **never run `kamal proxy reboot` from this
  repo**.
- **TLS** is terminated by Caddy → `proxy.ssl: false`. `assume_ssl`/`force_ssl`
  stay on (Caddy sends `X-Forwarded-Proto: https`).
- **Postgres** — dedicated accessory, upgraded 16 → 18.6 (same as easy-loans)
  via `pg_dump`/`pg_restore`. Host port **5435**: 5432 is medistock's db, 5433
  easy-loans' db, 5434 medistock's self-hosted CI runner. Postgres 18 keeps
  its data under `/var/lib/postgresql/18/docker`, so the volume mounts
  `/var/lib/postgresql`.
- **Typesense** — dedicated accessory. Its data is **not** migrated: the index
  is rebuilt from Postgres (`bin/rails typesense:recreate`, also run by
  `.kamal/hooks/post-deploy`).
- **UniOne** — HTTP API (`lib/email/providers/uni_one_provider.rb`), sender
  `noreply@ilvmx.org`. The sending domain doesn't change → no UniOne DNS/domain
  changes.
- **Stripe** — live keys and the existing live webhook endpoint
  (`https://tienda.ilvmx.org/webhooks/stripe`). The URL doesn't change; it just
  reaches the new server after the DNS switch. Checkout `success_url`/`cancel_url`
  are built from the request host, so both hosts work.
- **Cloudflare R2** — same bucket. Backoffice cover uploads are *direct
  uploads* from the browser, so the bucket's CORS must allow the new origin.
- **Registry** — Kamal's local registry tunnel (`localhost:5555`), like the
  other apps; Docker Hub and `KAMAL_REGISTRY_PASSWORD` are no longer used.
- **SSH** — port 20202, user `deploy` (already set up for the other apps).

## Changes made

### This repo

- `config/deploy.yml` — `proxy` (`ssl: false`, `hosts: [tienda.ilvmx.org,
  tienda.mibotica.app]`), local registry, `ssh.user: deploy`, `APP_HOST`,
  `RAILS_LOG_LEVEL: debug` removed, `dbc --include-password`, Postgres 18.6 on
  5435 with the new data mount.
- `.kamal/secrets` — `KAMAL_REGISTRY_PASSWORD` removed.
- `config/environments/production.rb` — mailer `default_url_options`/`asset_host`
  from `APP_HOST` (always `https`), `config.hosts` for both hosts with `/up`
  excluded.
- `README.md` — deployment section points here.

### medistock repo (`config/Caddyfile`)

- New `tienda.mibotica.app { }` block (active).
- New `tienda.ilvmx.org { }` block, **commented out** — you uncomment it only
  after the DNS switch. Enabling it earlier makes Caddy fail the ACME
  challenge (the name still resolves to the old server) and back off,
  delaying the certificate after the switch. Both variants pass
  `caddy validate`.

## Runbook

All `kamal` commands run from this repo on the branch with these changes,
with Docker running locally (the registry tunnel needs it).

### A. Days before the window

1. **DNS TTL** — lower the TTL of the `tienda.ilvmx.org` A record to 300s. Do
   it at least one *old* TTL period before the window, or caches keep the old
   IP longer than an hour.
2. **DNS for `tienda.mibotica.app`** — confirm it resolves to the new server
   (the `*.mibotica.app` wildcard should already cover it):
   ```bash
   dig +short tienda.mibotica.app
   ```
3. **`.env.production`** — set `SERVER_IP` to the **new** server. Everything
   else stays as it is (`POSTGRES_USER` must remain `rails`, the user the
   accessory creates). `KAMAL_REGISTRY_PASSWORD` can be removed.
4. **UniOne** — in the UniOne dashboard check whether the API key has an IP
   allowlist; if it has one, add the new server's IP.
5. **Cloudflare R2** — in the bucket's CORS policy, add
   `https://tienda.mibotica.app` to `AllowedOrigins` (keep
   `https://tienda.ilvmx.org`).
6. **New server preflight** (read-only):
   ```bash
   export SERVER_IP=...        # new server, terminal only
   ssh -p 20202 deploy@$SERVER_IP 'ss -ltn | grep -E ":(5435|8108)\b" || echo "ports free"; df -h /; free -m'
   ```

### B. Pre-stage (no downtime, before the window)

1. **Caddy route** — from the medistock repo (branch
   `chore/caddy-ilv-store-route`):
   ```bash
   dotenv -f .env.production kamal accessory reboot caddy
   ```
   This restarts TLS for every app on the server for a few seconds — do it
   off-peak. Then:
   ```bash
   curl -sI https://tienda.mibotica.app | head -1   # valid cert; 404 from kamal-proxy is expected (no app yet)
   ```
2. **First deploy** — from this repo:
   ```bash
   dotenv -f .env.production kamal setup
   ```
   Boots `ilv_store-db` (creates the 4 databases via `db/production.sql`) and
   `ilv_store-typesense`, builds and deploys the app (`db:prepare` loads an
   empty schema), and the post-deploy hook creates the empty search index.
3. **Check it's healthy**:
   ```bash
   dotenv -f .env.production kamal details
   curl -fsS https://tienda.mibotica.app/up
   dotenv -f .env.production kamal logs     # Ctrl-C to exit
   ```
   Opening `https://tienda.mibotica.app` should show an empty store.

If anything here fails, production is untouched — fix and retry.

### C. Migration window (< 1 hour)

```bash
export SERVER_IP=...        # new server
export OLD_SERVER_IP=...    # current production server
```

**1. Maintenance on the old server** (≈1 min)

The old server is no longer described by `deploy.yml`, so talk to its
kamal-proxy directly (this is exactly what `kamal app maintenance` runs):

```bash
ssh -p 20202 root@$OLD_SERVER_IP \
  "docker exec kamal-proxy kamal-proxy stop ilv_store-web --message='Estamos actualizando la tienda. Volvemos en unos minutos.'"
curl -sI https://tienda.ilvmx.org | head -1    # expect 503
```

**2. Check the old job queue is empty** (≈1 min)

```bash
ssh -p 20202 root@$OLD_SERVER_IP \
  "docker exec ilv_store-db psql -U rails -d ilv_store_production_queue -c 'select (select count(*) from solid_queue_ready_executions) ready, (select count(*) from solid_queue_claimed_executions) claimed;'"
```

Both should be `0` (wait a minute and retry if not). Only the primary DB is
migrated; cache, queue and cable are recreated empty on the new server.

**3. Dump production** (≈2–5 min)

```bash
ssh -p 20202 root@$OLD_SERVER_IP \
  "docker exec ilv_store-db pg_dump -U rails -Fc ilv_store_production" > tmp/ilv_store_production.dump
ls -lh tmp/ilv_store_production.dump             # sanity check: not 0 bytes
```

`tmp/` is gitignored. The dump contains customer data — delete it once the
migration is confirmed.

**4. Restore on the new server** (≈5 min)

Stop the app so nothing holds connections, recreate the empty primary DB,
restore, and boot again (`db:prepare` in the entrypoint runs any pending
migrations):

```bash
dotenv -f .env.production kamal app stop

ssh -p 20202 deploy@$SERVER_IP \
  "docker exec ilv_store-db dropdb -U rails ilv_store_production && docker exec ilv_store-db createdb -U rails ilv_store_production"

ssh -p 20202 deploy@$SERVER_IP \
  "docker exec -i ilv_store-db pg_restore -U rails -d ilv_store_production --no-owner --no-privileges" < tmp/ilv_store_production.dump

dotenv -f .env.production kamal app boot
dotenv -f .env.production kamal typesense-reindex
```

Compare a few counts between old and new:

```bash
Q="select (select count(*) from users) users, (select count(*) from orders) orders, (select count(*) from products) products;"
ssh -p 20202 root@$OLD_SERVER_IP   "docker exec ilv_store-db psql -U rails -d ilv_store_production -c \"$Q\""
ssh -p 20202 deploy@$SERVER_IP     "docker exec ilv_store-db psql -U rails -d ilv_store_production -c \"$Q\""
```

**5. Test on `https://tienda.mibotica.app`** (≈10–15 min)

Emails link to `tienda.ilvmx.org` (the canonical host), which still shows the
maintenance page until the DNS switch — that's expected.

- [ ] Home and catalog render; product cover images load (R2)
- [ ] Search returns results (Typesense)
- [ ] Log in with an existing account (proves the data and `RAILS_MASTER_KEY`)
- [ ] Sign up a test account → verification email arrives (UniOne)
- [ ] Password reset email arrives (UniOne)
- [ ] Cart → address with postal-code lookup → order summary (stop before paying)
- [ ] Backoffice: dashboard, orders list, an order detail
- [ ] Backoffice: upload a **new** cover image on a test/draft product (R2 direct upload + CORS). Don't delete or replace images of real products — the bucket is shared with production.
- [ ] `/jobs` (Mission Control) loads; `release_expired_reservations` is listed as recurring
- [ ] `dotenv -f .env.production kamal logs` shows no errors; nothing new in Sentry

If something is broken and can't be fixed quickly → [Rollback](#rollback).

**6. Switch DNS** (≈1 min + propagation)

Point the `tienda.ilvmx.org` A record at the new server IP. Then watch it
propagate:

```bash
dig +short tienda.ilvmx.org @1.1.1.1
dig +short tienda.ilvmx.org @8.8.8.8
```

**7. Enable `tienda.ilvmx.org` in Caddy** (≈2 min) — once `dig` returns the new IP

In the medistock repo, uncomment the `tienda.ilvmx.org { … }` block in
`config/Caddyfile`, then:

```bash
dotenv -f .env.production kamal accessory reboot caddy
```

Watch the certificate get issued:

```bash
ssh -p 20202 deploy@$SERVER_IP "docker logs --since 5m \$(docker ps -qf name=caddy) 2>&1 | grep -i tienda.ilvmx.org"
curl -fsS https://tienda.ilvmx.org/up
```

**8. Verify live on `https://tienda.ilvmx.org`** (≈10 min)

- [ ] Site loads with a valid certificate, no maintenance page
- [ ] Log in, search, browse
- [ ] **Real purchase** with a low-value product (or a card you'll refund):
      Stripe Checkout → redirected back to the order → order marked paid
- [ ] Stripe dashboard → Developers → Webhooks → live endpoint: latest
      deliveries return `2xx`. Any events that failed during the window
      (503 from maintenance) are retried by Stripe automatically — check they
      end up delivered.
- [ ] Order email arrives (customer + `SALES_EMAIL_ADDRESS` cc), links point to `tienda.ilvmx.org`
- [ ] Backoffice: mark an order in transit → in-transit email (optional)
- [ ] `/jobs` shows jobs being processed; no errors in Sentry/logs

Done. Leave the old server in maintenance (don't resume it).

### Rollback

- **Before step 6 (DNS)** — customers never reached the new server. Resume
  the old one:
  ```bash
  ssh -p 20202 root@$OLD_SERVER_IP "docker exec kamal-proxy kamal-proxy resume ilv_store-web"
  ```
- **After step 6** — point the DNS record back to the old IP, then resume the
  old server as above. Orders placed on the new server in between must be
  reconciled by hand (check Stripe payments since the switch time).

### D. After the migration

- [ ] Delete `tmp/ilv_store_production.dump`
- [ ] Commit the uncommented `tienda.ilvmx.org` block in medistock and merge
      both branches
- [ ] Restore the `tienda.ilvmx.org` DNS TTL to its normal value (after a day or two)
- [ ] Set up a scheduled `pg_dump` backup of `ilv_store-db`, stored off the server
- [ ] Delete the `ilv_store` repository on Docker Hub and its access token
- [ ] After ~7 days without issues: final dump of the old server, then decommission it
- [ ] Update this plan's status and note anything that deviated

## Risks

| Risk | Mitigation |
| ---- | ---------- |
| `tienda.mibotica.app` caught by medistock's on-demand `:443` block | Named Caddy block, validated before the window (B.1) |
| Rebinding the shared kamal-proxy | No `proxy.run`; never `kamal proxy reboot` from this repo |
| Port clash with medistock CI runner (5434) | ilv_store-db on 5435; preflight check (A.6) |
| Orders written after the dump | Old server in maintenance before the dump (C.1) |
| Jobs lost or run twice | Queue drained before the dump; queue DB not migrated (C.2) |
| Staging tests delete production R2 files | Only upload new images during testing, no deletes |
| Stripe webhooks missed during the window | Stripe retries failed deliveries; verified in C.8 |
| Slow DNS propagation | TTL lowered days before (A.1); old server keeps showing maintenance |
| Postgres 16 → 18 restore issue | Restore errors are visible immediately in C.4 → rollback before DNS |
| Let's Encrypt failures for `tienda.ilvmx.org` | Caddy block enabled only after DNS points to the new server (C.7) |
