# Plan 02 — Publish / unpublish products

## Status

Implemented ✅

## Goal

Let admins hide a product from the store without deleting it. A hidden product
must not be visible, searchable, added to a cart, or bought, but it keeps its
data, stock, and order history, and can be published again at any time.

## Naming

"Enable/disable" suggests the product is broken or switched off. What we're
really controlling is whether customers can see it in the store, which
e-commerce tools usually call **publishing**.

| Option | Verdict |
| ------ | ------- |
| `enabled` / `disabled` | Vague: disabled *how*? |
| `active` / `inactive` | Easy to confuse with stock ("inactive" = out of stock?) |
| `visible` / `hidden` | Clear, but describes only the catalog; a hidden product also can't be bought |
| `archived` | Suggests permanent retirement, not a temporary toggle |
| **`published` / `unpublished`** | ✅ Standard wording (Shopify, WooCommerce, CMSs), covers "not in the store at all" |

**Decision:** `published` in the code. UI copy:

| | es | en |
| - | -- | -- |
| Status badge | Publicado / Oculto | Published / Hidden |
| Actions | Publicar / Ocultar | Publish / Unpublish |

## Data model

Migration adding a boolean to `products`:

```ruby
add_column :products, :published, :boolean, default: true, null: false
add_index  :products, :published
```

- `default: true` keeps every existing product visible after the deploy, so
  nothing changes for customers until an admin hides something.
- New products are also published by default (current behavior). If we'd
  rather create them hidden and publish once they're reviewed, flip the
  default in the form, not the column.
- A boolean is enough for now. If we later need scheduled publishing, it can
  become `published_at` without changing the public API (`published?`,
  `.published`).

`Product`:

```ruby
scope :published, -> { where(published: true) }
scope :unpublished, -> { where(published: false) }

def publish!   = update!(published: true)
def unpublish! = update!(published: false)
```

Both go through `update!`, so the existing `after_save :index_in_typesense`
callback keeps the search index in sync.

## Where hidden products must disappear

| Place | File | Change |
| ----- | ---- | ------ |
| Catalog list | `app/controllers/products_controller.rb#list_products` | Add `.published` |
| Product detail | `ProductsController#show` | `Product.published.find` → 404 for hidden products |
| Search (Typesense) | `app/models/product/typesense_config.rb`, `ProductsController#search_products` | Add a `published` field (`bool`) to the schema and document; search with `filter_by: 'published:true'`. Hits are loaded in one query with `Product.published.includes(...).where(id: ids)` (keeping Typesense's order), so a stale index can't leak a hidden product. This also replaced the previous one-`find`-per-hit loop. Dropped hits are subtracted from Typesense's `found`, so the results total and pagination only count what's shown |
| Add to cart | `app/models/cart/item.rb` | New validation: product must be published (`errors.add(:product, :unpublished)`); the stock check is skipped for hidden products so only one error shows |
| Cart already containing it | `app/views/carts/_item.html.erb` | Show "no longer available" and hide the quantity controls; the customer can remove it |
| Checkout | `app/forms/order_form.rb` | `validate :cart_products_published` — one query (`current_cart.products.unpublished.exists?`), error on `:base` asking to remove the hidden items. Because validation runs before the transaction, `submit` checks again with the cart's products locked (`SELECT … FOR UPDATE`, id order): a concurrent unpublish either commits first and aborts the order, or waits until the order and its reservation are committed. The order is never created with a hidden product, so no stock is reserved for it (`Order#reserve_stock!`) |

Unaffected on purpose:

- **Past orders** (`orders#index/show`, backoffice orders, emails) still load
  the product through `Order::Item`, so history keeps its titles and covers.
- **Checkout sessions already at Stripe** when the product is hidden can still
  complete: stock was reserved and the customer is paying. Hiding stops *new*
  purchases only.
- **Stock** isn't touched; publishing again restores the product as it was.

## Typesense

- Schema gets `{ name: 'published', type: 'bool' }`. Because the schema
  changes, the collection must be recreated: the post-deploy hook already runs
  `bin/rails typesense:recreate`, so this happens automatically on deploy.
- Filtering (instead of deleting the document on unpublish) keeps one code
  path for indexing and makes re-publishing instant.

## Backoffice

Routes (a nested singular resource instead of custom member actions):

```ruby
namespace :backoffice do
  resources :products, only: %i[index new edit create update] do
    resource :publication, only: %i[create destroy], module: :products
  end
end
```

- `POST   /backoffice/products/:product_id/publication` → publish
- `DELETE /backoffice/products/:product_id/publication` → unpublish

`Backoffice::Products::PublicationsController` (inherits
`Backoffice::BaseController`, so admin-only):

- Finds the `Product` by `params[:product_id]`, calls `publish!`/`unpublish!`.
- Responds with a Turbo Stream that replaces the product card and appends the
  flash message, so the list updates in place without a reload.

Products list (`backoffice/products?type=book` — `index.html.erb`,
`_book_card.html.erb`). **Decision: a button, not a toggle switch** — the label
says exactly what will happen, and the confirmation fits naturally.

```
┌──────────────────────────────────────────────────────────────┐
│ ILV-0012   ● Publicado                  [ Ocultar ] [Editar] │
│ Subtitle…                                                    │
└──────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────┐
│ ILV-0034   ○ Oculto   (card dimmed)     [ Publicar ] [Editar]│
└──────────────────────────────────────────────────────────────┘
```

- **Badge** next to the internal code: "● Publicado" (green) / "○ Oculto" (gray).
- **Button** next to "Editar": "Ocultar" when published, "Publicar" when
  hidden. It saves immediately (no Save step): `button_to` submits the form,
  and the Turbo Stream response replaces that card and shows the flash.
  "Ocultar" asks for confirmation first ("Los clientes dejarán de ver este
  producto"); "Publicar" doesn't.
  ```erb
  <% if product.published? %>
    <%= button_to t('.actions.unpublish'), backoffice_product_publication_path(product),
          method: :delete, form: { data: { turbo_confirm: t('.confirm_unpublish') } } %>
  <% else %>
    <%= button_to t('.actions.publish'), backoffice_product_publication_path(product) %>
  <% end %>
  ```
  Note: the publication route takes the **Product** id, while the existing
  "Editar" link passes the Book id (`product.productable_id`).
- The card gets `id="<%= dom_id(product) %>"` so the Turbo Stream can replace it.
- Hidden cards are rendered dimmed so they stand out while scanning.
- The button row keeps `flex items-center gap-2` (no `flex-wrap`): the
  existing "Editar" link is `w-full`, so wrapping would push it onto its own
  line. The badge row does use `flex-wrap`.
- Filter tabs (Todos / Publicados / Ocultos) were **not** built — left for a
  follow-up if the list grows.

The product form (edit drawer) doesn't change: publishing is its own action,
so an admin can't hide a product by accident while editing its price.

## i18n

Storefront text in both `es` and `en`:

- `config/locales/views/carts/` — `carts.item.unavailable`
- `config/locales/models/cart/item/` — `cart/item.product.unpublished`
- `config/locales/forms/order_form/` (new) — `activemodel…order_form.base.unpublished_products`

Backoffice text in `es` only (the backoffice always renders in Spanish):

- `config/locales/views/backoffice/products/es.yml` — `book_card.status.*`,
  `book_card.actions.publish/unpublish`, `book_card.confirm_unpublish`
- `config/locales/controllers/backoffice/products/publications/es.yml` — flash messages

## Tests

- **Model** (`test/models/product_test.rb`): `published` defaults to `true`;
  `.published`/`.unpublished` scopes; `publish!`/`unpublish!` update the flag.
- **Typesense** (`test/models/product/…`): `typesense_document` includes
  `published`; schema includes the field.
- **Storefront** (`test/controllers/products_controller_test.rb`): hidden
  products are not listed; `show` returns 404; search passes
  `filter_by: 'published:true'` (the mock client ignores params, so stub
  `Product.search` and assert the options).
- **Cart** (`test/models/cart/item_test.rb`, `test/controllers/carts/…`):
  can't add a hidden product; the cart renders a hidden item as unavailable.
- **Checkout** (`test/controllers/orders_controller_test.rb` / form test):
  order creation fails with a hidden product in the cart, and no stock is
  reserved.
- **Backoffice** (`test/controllers/backoffice/products/publications_controller_test.rb`):
  admin can publish/unpublish; non-admin is rejected; the Turbo Stream
  replaces the card.
- **Order history**: an order whose product was hidden still renders.

## Rollout

1. Deploy: the migration adds the column (all products stay published) and the
   post-deploy hook recreates the Typesense collection with the new field.
2. Smoke test: hide a test product → it disappears from the catalog and
   search, its URL returns 404, adding it to a cart fails; publish it again →
   it's back.

## Out of scope

- Scheduled publishing (publish at a future date).
- Per-locale visibility.
- Hiding products automatically when stock reaches zero (stock and visibility
  stay independent).
