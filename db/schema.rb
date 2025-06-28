# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_28_154714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_id", null: false
    t.string "street_and_number"
    t.string "postal_code", null: false
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "state_id", null: false
    t.uuid "city_id", null: false
    t.string "neighborhood"
    t.string "full_name", null: false
    t.string "phone_number"
    t.boolean "default", default: false, null: false
    t.string "addressable_type", null: false
    t.uuid "addressable_id", null: false
    t.index ["addressable_id", "default"], name: "index_addresses_on_addressable_id_and_default", unique: true, where: "(\"default\" = true)"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["state_id"], name: "index_addresses_on_state_id"
  end

  create_table "books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "language", null: false
    t.string "language_zone", null: false
    t.string "edition_number", null: false
    t.string "pages_number", null: false
    t.string "internal_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internal_code"], name: "index_books_on_internal_code", unique: true
  end

  create_table "cart_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.uuid "cart_id", null: false
    t.integer "quantity", default: 1, null: false
    t.boolean "out_of_stock", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "country_state_cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "state_id"], name: "index_country_state_cities_on_name_and_state_id", unique: true
    t.index ["state_id"], name: "index_country_state_cities_on_state_id"
  end

  create_table "country_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.uuid "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "country_id"], name: "index_country_states_on_code_and_country_id", unique: true
    t.index ["country_id"], name: "index_country_states_on_country_id"
    t.index ["name", "country_id"], name: "index_country_states_on_name_and_country_id", unique: true
  end

  create_table "mx_postal_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "state_id", null: false
    t.uuid "city_id", null: false
    t.string "postal_code"
    t.string "neighborhood"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_mx_postal_codes_on_city_id"
    t.index ["postal_code", "neighborhood"], name: "index_mx_postal_codes_on_postal_code_and_neighborhood", unique: true
    t.index ["state_id"], name: "index_mx_postal_codes_on_state_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_status", default: "created", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["workflow_status"], name: "index_orders_on_workflow_status"
  end

  create_table "product_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.string "locale", null: false
    t.string "title", null: false
    t.string "subtitle", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "locale"], name: "index_product_translations_on_product_id_and_locale", unique: true
    t.index ["product_id"], name: "index_product_translations_on_product_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "stock", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "productable_type", null: false
    t.uuid "productable_id", null: false
    t.index ["productable_type", "productable_id"], name: "index_products_on_productable"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme_preference", default: "light", null: false
    t.boolean "verified", default: false, null: false
    t.string "name", null: false
    t.uuid "country_id", null: false
    t.string "role", default: "customer", null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "country_state_cities", column: "city_id"
  add_foreign_key "addresses", "country_states", column: "state_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "country_state_cities", "country_states", column: "state_id"
  add_foreign_key "country_states", "countries"
  add_foreign_key "mx_postal_codes", "country_state_cities", column: "city_id"
  add_foreign_key "mx_postal_codes", "country_states", column: "state_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_translations", "products"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "countries"
end
