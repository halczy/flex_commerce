# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 150) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "recipient"
    t.string "contact_number"
    t.string "country_region"
    t.string "province_state"
    t.string "city"
    t.string "district"
    t.string "community"
    t.string "street"
    t.string "full_address"
    t.string "addressable_type"
    t.uuid "addressable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "application_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.boolean "status"
    t.string "encrypted_value"
    t.string "encrypted_value_iv"
    t.string "plain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_application_configurations_on_name"
  end

  create_table "carts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.integer "status", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "display_order"
    t.integer "flavor", default: 0
    t.boolean "hide", default: true
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "categorizations", force: :cascade do |t|
    t.uuid "product_id"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["product_id"], name: "index_categorizations_on_product_id"
  end

  create_table "geos", id: :string, force: :cascade do |t|
    t.string "parent_id"
    t.string "name"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_geos_on_name"
    t.index ["parent_id"], name: "index_geos_on_parent_id"
  end

  create_table "images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "display_order", default: 0
    t.string "description"
    t.string "title"
    t.boolean "in_use", default: false
    t.integer "source_channel"
    t.text "image_data"
    t.string "imageable_type"
    t.uuid "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status"
    t.datetime "purchased_at"
    t.datetime "returned_at"
    t.decimal "purchase_weight"
    t.integer "purchase_price_cents", default: 0, null: false
    t.string "purchase_price_currency", default: "CNY", null: false
    t.uuid "user_id"
    t.uuid "product_id"
    t.uuid "cart_id"
    t.uuid "order_id"
    t.uuid "shipping_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_inventories_on_cart_id"
    t.index ["order_id"], name: "index_inventories_on_order_id"
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["shipping_method_id"], name: "index_inventories_on_shipping_method_id"
    t.index ["user_id"], name: "index_inventories_on_user_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.integer "shipping_cost_cents", default: 0, null: false
    t.string "shipping_cost_currency", default: "CNY", null: false
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "CNY", null: false
    t.integer "status"
    t.integer "processor"
    t.integer "variety"
    t.uuid "order_id"
    t.jsonb "processor_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["processor"], name: "index_payments_on_processor"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["variety"], name: "index_payments_on_variety"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "tag_line"
    t.string "sku"
    t.decimal "weight"
    t.text "introduction"
    t.text "description"
    t.text "specification"
    t.integer "price_market_cents", default: 0, null: false
    t.string "price_market_currency", default: "CNY", null: false
    t.integer "price_member_cents", default: 0, null: false
    t.string "price_member_currency", default: "CNY", null: false
    t.integer "price_reward_cents", default: 0, null: false
    t.string "price_reward_currency", default: "CNY", null: false
    t.integer "cost_cents", default: 0, null: false
    t.string "cost_currency", default: "CNY", null: false
    t.boolean "strict_inventory", default: true
    t.boolean "digital", default: false
    t.integer "status", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["price_market_cents"], name: "index_products_on_price_market_cents"
    t.index ["price_member_cents"], name: "index_products_on_price_member_cents"
    t.index ["price_reward_cents"], name: "index_products_on_price_reward_cents"
    t.index ["sku"], name: "index_products_on_sku"
    t.index ["status"], name: "index_products_on_status"
    t.index ["tag_line"], name: "index_products_on_tag_line"
    t.index ["weight"], name: "index_products_on_weight"
  end

  create_table "products_shipping_methods", id: false, force: :cascade do |t|
    t.uuid "product_id"
    t.uuid "shipping_method_id"
    t.index ["product_id"], name: "index_products_shipping_methods_on_product_id"
    t.index ["shipping_method_id"], name: "index_products_shipping_methods_on_shipping_method_id"
  end

  create_table "shipping_methods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "variety"
    t.uuid "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_shipping_methods_on_product_id"
  end

  create_table "shipping_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "geo_code"
    t.integer "init_rate_cents", default: 0, null: false
    t.string "init_rate_currency", default: "CNY", null: false
    t.integer "add_on_rate_cents", default: 0, null: false
    t.string "add_on_rate_currency", default: "CNY", null: false
    t.uuid "shipping_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geo_code"], name: "index_shipping_rates_on_geo_code"
    t.index ["shipping_method_id"], name: "index_shipping_rates_on_shipping_method_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "CNY", null: false
    t.integer "variety"
    t.integer "status"
    t.text "note"
    t.jsonb "metadata"
    t.string "transactable_type"
    t.uuid "transactable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transactable_type", "transactable_id"], name: "index_transactions_on_transactable_type_and_transactable_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "email"
    t.string "cell_number"
    t.integer "member_id"
    t.string "password_digest"
    t.string "remember_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cell_number"], name: "index_users_on_cell_number", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["member_id"], name: "index_users_on_member_id", unique: true
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "balance_cents", default: 0, null: false
    t.string "balance_currency", default: "CNY", null: false
    t.integer "pending_cents", default: 0, null: false
    t.string "pending_currency", default: "CNY", null: false
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "carts", "users"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "products"
  add_foreign_key "inventories", "carts"
  add_foreign_key "inventories", "orders"
  add_foreign_key "inventories", "products"
  add_foreign_key "inventories", "shipping_methods"
  add_foreign_key "inventories", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "shipping_methods", "products"
  add_foreign_key "shipping_rates", "shipping_methods"
  add_foreign_key "wallets", "users"
end
