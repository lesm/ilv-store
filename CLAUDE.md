# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

ILV Store is a public e-commerce app for selling books (storefront + admin
backoffice), built on Rails 8.1 and Ruby 4.0.6 (see `.ruby-version`).

## Public Repository

This repo is **public on GitHub**. Never commit, and never write into code, docs
or plans:
- Server IPs, SSH hosts, local filesystem paths, or machine-specific details
- API keys, passwords, tokens, account IDs, webhook secrets
- Personal emails or customer data

Real values live only in the gitignored `.env*` files and `config/master.key`.
In docs, use placeholders (`$SERVER_IP`, `YOUR_API_KEY`) instead.

## Commands

- `bin/dev` — web server + Tailwind watcher + Solid Queue worker (`Procfile.dev`)
- `bin/rails test` — unit/integration tests (parallel, excludes system tests)
- `bin/rails test:system` — system tests (Selenium, headless Chrome)
- `bin/rails test:all` — everything
- `bin/rails test test/models/product_test.rb` / `:29` — a single file or a single test by line
- `bin/rubocop` — Ruby lint (see `.rubocop.yml`)
- `bundle exec erb_lint --lint-all` — ERB lint
- `npx @herb-tools/formatter "app/views/**/*.erb"` then `npx @herb-tools/linter "app/views/**/*.erb"` — ERB formatting/linting (herb)
- `bundle exec database_consistency` — DB constraints vs. model validations
- `bundle exec brakeman` / `bundle audit` / `bin/importmap audit` — security and dependency audits
- `bin/ci` — CI gate (`config/ci.rb`)
- `bin/pre-push` — **full local gate before opening a PR**: herb format, erb_lint, rubocop, database_consistency, herb lint, bundle audit, brakeman, importmap audit, `test:all`. Run it before pushing.
- `bin/rails typesense:recreate` — drop, recreate and reindex the Typesense collection
- `bin/rails mx_postal_codes:load` — load SEPOMEX postal codes
- `bin/rails db:seed` — states and the initial book list

Coverage is enforced at **100%** (`minimum_coverage 100` in `test/test_helper.rb`),
so every new line of app code needs a test.

## Docs Discipline

Feature plans live in `docs/plans/NN-title.md`. **Always**, at the end of every
implementation task:

1. If a plan exists for the feature, set its `## Status` to `Implemented ✅`.
2. If the implementation diverged from the plan (different approach, renamed
   fields, post-review refactors), update the plan to describe what was
   actually built — not the original design. This also applies to follow-up
   bug fixes and code-review changes on an already-implemented plan.
3. If a new plan fundamentally changes something described in an older one,
   add a banner to the top of the old plan at the moment the new one is marked
   `Implemented ✅`:
   ```
   > ⚠️ **Partially superseded by [Plan NN — Title](NN-title.md).**
   > <one line saying what changed and what's still valid>
   ```
   Treat any plan with a `⚠️ Superseded` banner as historical context only.

Plans are public too — the [Public Repository](#public-repository) rules apply.

## Stack

- PostgreSQL with 4 databases per environment: primary, cache, queue, cable
- Solid Queue / Solid Cache / Solid Cable (no Redis); Mission Control Jobs at `/jobs`
- Hotwire (Turbo + Stimulus), Importmap (no JS bundler), Propshaft
- Tailwind CSS v4 (`tailwindcss-rails`, CSS-first config in `app/assets/tailwind/application.css`, class-based dark mode)
- Pagy for pagination
- Typesense for product search
- Stripe Checkout for payments
- UniOne (HTTP API) for transactional email
- Active Storage on Cloudflare R2 (S3-compatible), served through the Rails proxy
- Sentry for error tracking
- Deploy: Kamal 2 — see `docs/plans/01-kamal-mibotica-deployment.md`
- Tests: Minitest + spec DSL (`minitest-spec-rails`), FactoryBot, Mocha, WebMock, Capybara/Selenium, SimpleCov, Bullet

## Architecture

### Routing and locales

- The storefront is bilingual: `es` (default) and `en` (`config/initializers/locales.rb`).
  Storefront routes live in `config/routes/application.rb`, drawn inside a
  `scope '(:locale)'` in `config/routes.rb`.
- The admin area is the `backoffice` namespace (not locale-scoped).
  `Backoffice::BaseController` requires an authenticated user with the `admin`
  role; every backoffice controller inherits from it.
- Stripe webhooks: `Webhooks::StripesController` (`POST /webhooks/stripe`).

### Catalog

- **Product** is the sellable unit, with a polymorphic `productable`
  (currently only **Book**, which holds the book-specific fields).
- **Product::Translation** holds per-locale `title`, `subtitle` and `price`
  (`es` price in MXN, `en` price in USD). `product.title`/`price` delegate to
  the translation for `I18n.locale`.
- Cover image via Active Storage (`has_one_attached :cover` with `small`/`medium`
  variants); backoffice uploads are direct uploads.
- **Search**: the `Searchable` concern (`app/models/concerns/searchable.rb`)
  indexes on `after_save` and removes on `after_destroy`;
  `Product::TypesenseConfig` defines the schema and document. Any schema change
  needs `typesense:recreate`, which `.kamal/hooks/post-deploy` runs on every deploy.
  In tests, `TYPESENSE_CLIENT` is `TypesenseMockClient` (`lib/typesense_mock_client.rb`).

### Inventory

- `Product::InventoryManageable`: `stock`, `reserved_stock`, `available_stock`,
  `reserve_stock!` (pessimistic lock). DB check constraints keep both counters ≥ 0.
- **StockReservation** holds stock while a customer is at Stripe Checkout;
  `ReleaseExpiredStockReservationsJob` (recurring, `config/recurring.yml`)
  releases expired ones.

### Cart and checkout

- **Cart** / **Cart::Item** — one cart per user; `Cart::Item` validates stock
  availability; totals include a shipping label price (**LabelPrice**, by
  weight range).
- **OrderForm** (`app/forms/`, inherits `ApplicationForm`) builds the **Order**
  from the cart inside a transaction. `Order` reserves stock on create.
- `Order#workflow_status`: `draft` → `pending` → `created` → `in_transit` →
  `delivered` (or `canceled`); `payment_status`: `pending`/`paid`/`failed`.
- Stripe Checkout session creation lives in `lib/payment/stripe/`.

### Email

- Mailers (`AccountMailer`, `OrderMailer`) only **build** messages;
  `EmailService` sends them through `Email::Providers::UniOneProvider`
  (`lib/email/providers/`). ActionMailer's delivery method is not used in
  production.
- Development uses `letter_opener`; jobs need the `bin/jobs` worker running
  (included in `bin/dev`).

### Development gotchas

- `gssencmode: disable` on dev/test Postgres connections is required on macOS:
  without it, Solid Queue's forked workers segfault (libpq's GSS check isn't fork-safe).
- `docker-compose.yml` runs Postgres locally. Search needs a Typesense server
  (defaults: `localhost:8108`, key from `TYPESENSE_API_KEY`; see `config/initializers/typesense.rb`).

## Conventions

- **Frozen string literals** in all Ruby files; single quotes (RuboCop).
- **All user-facing text goes through I18n** — never hard-code UI strings.
  Storefront text needs both `es` and `en` keys
  (`config/locales/views/<controller>/{es,en}.yml`, `config/locales/models/<model>/`).
- **The backoffice is Spanish-only**: `Backoffice::BaseController` doesn't use
  `switch_locale`, so it always renders in `es`. Backoffice text goes in `es.yml`
  only. The backoffice `en.yml` files are not an English UI — they hold labels for
  the US-translation fields of the product form (`t(..., locale: tf.object.locale)`).
- **Thin controllers**: orchestration goes to form objects (`app/forms/`),
  behavior to model concerns under the model's own folder
  (`app/models/product/inventory_manageable.rb` → `Product::InventoryManageable`).
- **Nested model names** for owned records: `Product::Translation`, `Cart::Item`,
  `Order::Item`.
- **New state-change endpoints**: prefer a nested resource over custom member
  actions (e.g. `resource :publication, only: %i[create destroy]` rather than
  `patch :publish` / `patch :unpublish`).
- **Operation objects** (external APIs, multi-step work) are called via
  `.new(...).<verb>` — name the method after what it does or returns, not `call`.
- **`unless` only for one-line early returns** — multi-line guards use `if`
  with a negated predicate (`_invalid?`, `_missing?`):
  ```ruby
  return unless token            # ✅

  if amount_invalid?             # ✅
    errors.add(:amount, :invalid)
    return render :edit, status: :unprocessable_content
  end
  ```
- **Turbo**: drawer pattern for backoffice new/edit (`request.variant = :drawer`,
  `*.html+drawer.erb`), Turbo Streams for flash messages and in-place updates.
- **Mobile-first** views: header rows with a title and actions use
  `flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between`; groups
  of buttons/badges use `flex-wrap`.
- Colors come from the theme scale (`primary-*`) defined in the Tailwind
  `@theme` — don't introduce new raw palette colors for app chrome.

### `params.expect`

Always use `params.expect` (Rails 8) instead of `params.require().permit()`.
For `has_many` nested attributes, wrap the key list in an outer array:

```ruby
# ✅ array of permitted hashes
params.expect(book: [{ product_attributes: [:id, { translations_attributes: [%i[id title locale price]] }] }])

# ❌ %i[] alone is a flat array of symbols, not an array of hashes
params.expect(book: [{ product_attributes: [:id, { translations_attributes: %i[id title locale price] }] }])
```

### Tests

- **Test file mirrors the source file**:
  `app/controllers/backoffice/products_controller.rb` →
  `test/controllers/backoffice/products_controller_test.rb`.
- Spec DSL: `describe '#GET index' do … test '…' do`, with `let` for setup.
- FactoryBot with traits for test data (`create(:user, :admin)`, `create(:book)`).
- Sign in with `authenticate_as(user)` (integration) or `sign_in(user, password)`
  (system) from `test/support/`.
- WebMock blocks real HTTP in tests; system tests stub UniOne
  (`test/application_system_test_case.rb`).
- Bullet raises on N+1 queries in tests — fix the query (`includes`), don't
  silence it.

## Database Migrations

- Derive the timestamp from the app clock, not by hand:
  `bin/rails runner "puts Time.current.strftime('%Y%m%d%H%M%S')"`.
- UUID primary keys (`id: :uuid`, `gen_random_uuid()`); foreign keys are
  `uuid` columns.
- Every model validation that can be enforced in the DB also gets a DB
  constraint (`null: false`, check constraints, unique indexes, FKs) —
  `database_consistency` checks this in `bin/pre-push`.
- Schema changes to `Product` that affect search also need a Typesense schema
  update (see [Catalog](#catalog)).
