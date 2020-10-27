# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_26_212814) do

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at", precision: 6, null: false
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vtex_addresses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "city_id", null: false
    t.string "identifier"
    t.string "address_type"
    t.string "receiver_name"
    t.string "postal_code"
    t.string "street"
    t.string "number"
    t.string "neighborhood"
    t.string "complement"
    t.string "reference"
    t.float "latitude", limit: 53
    t.float "longitude", limit: 53
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["city_id"], name: "index_vtex_addresses_on_city_id"
    t.index ["identifier"], name: "index_vtex_addresses_on_identifier", unique: true
  end

  create_table "vtex_cities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "state_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "state_id"], name: "index_vtex_cities_on_name_and_state_id", unique: true
    t.index ["state_id"], name: "index_vtex_cities_on_state_id"
  end

  create_table "vtex_clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "first_name"
    t.string "last_name"
    t.string "document_type"
    t.string "document"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_clients_on_identifier", unique: true
  end

  create_table "vtex_countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "acronym"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["acronym"], name: "index_vtex_countries_on_acronym", unique: true
  end

  create_table "vtex_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "seller_id", null: false
    t.string "identifier"
    t.integer "quantity"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "selling_price", precision: 8, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier", "order_id", "selling_price"], name: "vtex_order_items_unique_index", unique: true
    t.index ["order_id"], name: "index_vtex_order_items_on_order_id"
    t.index ["product_id"], name: "index_vtex_order_items_on_product_id"
    t.index ["seller_id"], name: "index_vtex_order_items_on_seller_id"
  end

  create_table "vtex_order_totals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "total_id", null: false
    t.decimal "value", precision: 8, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id", "total_id"], name: "index_vtex_order_totals_on_order_id_and_total_id"
    t.index ["order_id"], name: "index_vtex_order_totals_on_order_id"
    t.index ["total_id"], name: "index_vtex_order_totals_on_total_id"
  end

  create_table "vtex_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "shipping_address_id", null: false
    t.string "identifier"
    t.integer "sequence"
    t.string "origin"
    t.string "status"
    t.string "status_description"
    t.decimal "value", precision: 8, scale: 2
    t.datetime "creation_date"
    t.datetime "last_change"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_vtex_orders_on_client_id"
    t.index ["identifier"], name: "index_vtex_orders_on_identifier", unique: true
    t.index ["shipping_address_id"], name: "index_vtex_orders_on_shipping_address_id"
  end

  create_table "vtex_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "sku_code"
    t.string "identifier"
    t.string "ean"
    t.string "image_url"
    t.string "detail_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_products_on_identifier", unique: true
  end

  create_table "vtex_sellers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.string "logo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_sellers_on_identifier", unique: true
  end

  create_table "vtex_states", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "acronym"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["acronym", "country_id"], name: "index_vtex_states_on_acronym_and_country_id", unique: true
    t.index ["country_id"], name: "index_vtex_states_on_country_id"
  end

  create_table "vtex_totals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_totals_on_identifier", unique: true
  end

  add_foreign_key "vtex_addresses", "vtex_cities", column: "city_id"
  add_foreign_key "vtex_cities", "vtex_states", column: "state_id"
  add_foreign_key "vtex_order_items", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_order_items", "vtex_products", column: "product_id"
  add_foreign_key "vtex_order_items", "vtex_sellers", column: "seller_id"
  add_foreign_key "vtex_order_totals", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_order_totals", "vtex_totals", column: "total_id"
  add_foreign_key "vtex_orders", "vtex_addresses", column: "shipping_address_id"
  add_foreign_key "vtex_orders", "vtex_clients", column: "client_id"
  add_foreign_key "vtex_states", "vtex_countries", column: "country_id"
end
