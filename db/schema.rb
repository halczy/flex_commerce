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

ActiveRecord::Schema.define(version: 20170713090737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "tag_line"
    t.string "sku"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["sku"], name: "index_products_on_sku"
  end

  create_table "users", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "email"
    t.string "cell_number"
    t.string "password_digest"
    t.string "remember_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cell_number"], name: "index_users_on_cell_number", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
