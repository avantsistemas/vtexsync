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

ActiveRecord::Schema.define(version: 2021_03_02_201915) do

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

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

  create_table "vtex_benefits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.string "description"
    t.boolean "featured"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_benefits_on_identifier", unique: true
  end

  create_table "vtex_brands", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_brands_on_identifier", unique: true
  end

  create_table "vtex_campaign_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "marketing_tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id", "marketing_tag_id"], name: "index_vtex_campaign_tags_on_campaign_id_and_marketing_tag_id", unique: true
    t.index ["campaign_id"], name: "index_vtex_campaign_tags_on_campaign_id"
    t.index ["marketing_tag_id"], name: "index_vtex_campaign_tags_on_marketing_tag_id"
  end

  create_table "vtex_campaigns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "utm_source"
    t.string "utm_partner"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "utmi_campaign"
    t.string "utmi_page"
    t.string "utmi_part"
    t.string "coupon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_vtex_campaigns_on_order_id", unique: true
  end

  create_table "vtex_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_categories_on_identifier", unique: true
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

  create_table "vtex_components", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_item_id", null: false
    t.bigint "product_id", null: false
    t.string "identifier"
    t.integer "index"
    t.integer "quantity"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "selling_price", precision: 8, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier", "index", "order_item_id"], name: "index_vtex_components_on_identifier_and_index_and_order_item_id", unique: true
    t.index ["order_item_id"], name: "index_vtex_components_on_order_item_id"
    t.index ["product_id"], name: "index_vtex_components_on_product_id"
  end

  create_table "vtex_connector_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.string "tid"
    t.string "auth_id"
    t.string "nsu"
    t.string "network"
    t.string "first_digits"
    t.string "last_digits"
    t.string "acquirer"
    t.string "message"
    t.string "return_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_vtex_connector_responses_on_payment_id", unique: true
  end

  create_table "vtex_countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "acronym"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["acronym"], name: "index_vtex_countries_on_acronym", unique: true
  end

  create_table "vtex_logistics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_item_id", null: false
    t.bigint "sla_id", null: false
    t.string "delivery_company"
    t.string "shipping_estimate"
    t.datetime "shipping_estimate_date"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "list_price", precision: 8, scale: 2
    t.decimal "selling_price", precision: 8, scale: 2
    t.string "transit_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_item_id"], name: "index_vtex_logistics_on_order_item_id", unique: true
    t.index ["sla_id"], name: "index_vtex_logistics_on_sla_id"
  end

  create_table "vtex_marketing_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_vtex_marketing_tags_on_name", unique: true
  end

  create_table "vtex_order_benefits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "benefit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["benefit_id"], name: "index_vtex_order_benefits_on_benefit_id"
    t.index ["order_id", "benefit_id"], name: "index_vtex_order_benefits_on_order_id_and_benefit_id", unique: true
    t.index ["order_id"], name: "index_vtex_order_benefits_on_order_id"
  end

  create_table "vtex_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "seller_id", null: false
    t.string "identifier"
    t.integer "index"
    t.integer "quantity"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "selling_price", precision: 8, scale: 2
    t.boolean "kit", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier", "index", "order_id"], name: "index_vtex_order_items_on_identifier_and_index_and_order_id", unique: true
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
    t.string "order_code"
    t.string "seller_order_code"
    t.integer "sequence"
    t.string "origin"
    t.string "status"
    t.string "status_description"
    t.decimal "value", precision: 8, scale: 2
    t.datetime "creation_date"
    t.datetime "authorized_date"
    t.datetime "invoiced_date"
    t.datetime "last_change"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_vtex_orders_on_client_id"
    t.index ["order_code"], name: "index_vtex_orders_on_order_code", unique: true
    t.index ["shipping_address_id"], name: "index_vtex_orders_on_shipping_address_id"
  end

  create_table "vtex_payment_systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.string "group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_payment_systems_on_identifier", unique: true
  end

  create_table "vtex_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.bigint "payment_system_id", null: false
    t.string "identifier"
    t.decimal "value", precision: 8, scale: 2
    t.integer "installments"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_payments_on_identifier", unique: true
    t.index ["payment_system_id"], name: "index_vtex_payments_on_payment_system_id"
    t.index ["transaction_id"], name: "index_vtex_payments_on_transaction_id"
  end

  create_table "vtex_product_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_vtex_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_vtex_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_vtex_product_categories_on_product_id"
  end

  create_table "vtex_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "brand_id"
    t.string "name"
    t.string "sku_code"
    t.string "identifier"
    t.string "ean"
    t.string "image_url"
    t.string "detail_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_vtex_products_on_brand_id"
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

  create_table "vtex_slas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_slas_on_identifier", unique: true
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

  create_table "vtex_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "identifier"
    t.string "merchant_name"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_vtex_transactions_on_identifier", unique: true
    t.index ["order_id"], name: "index_vtex_transactions_on_order_id"
  end

  add_foreign_key "vtex_addresses", "vtex_cities", column: "city_id"
  add_foreign_key "vtex_campaign_tags", "vtex_campaigns", column: "campaign_id"
  add_foreign_key "vtex_campaign_tags", "vtex_marketing_tags", column: "marketing_tag_id"
  add_foreign_key "vtex_campaigns", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_cities", "vtex_states", column: "state_id"
  add_foreign_key "vtex_components", "vtex_order_items", column: "order_item_id"
  add_foreign_key "vtex_components", "vtex_products", column: "product_id"
  add_foreign_key "vtex_connector_responses", "vtex_payments", column: "payment_id"
  add_foreign_key "vtex_logistics", "vtex_order_items", column: "order_item_id"
  add_foreign_key "vtex_logistics", "vtex_slas", column: "sla_id"
  add_foreign_key "vtex_order_benefits", "vtex_benefits", column: "benefit_id"
  add_foreign_key "vtex_order_benefits", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_order_items", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_order_items", "vtex_products", column: "product_id"
  add_foreign_key "vtex_order_items", "vtex_sellers", column: "seller_id"
  add_foreign_key "vtex_order_totals", "vtex_orders", column: "order_id"
  add_foreign_key "vtex_order_totals", "vtex_totals", column: "total_id"
  add_foreign_key "vtex_orders", "vtex_addresses", column: "shipping_address_id"
  add_foreign_key "vtex_orders", "vtex_clients", column: "client_id"
  add_foreign_key "vtex_payments", "vtex_payment_systems", column: "payment_system_id"
  add_foreign_key "vtex_payments", "vtex_transactions", column: "transaction_id"
  add_foreign_key "vtex_product_categories", "vtex_categories", column: "category_id"
  add_foreign_key "vtex_product_categories", "vtex_products", column: "product_id"
  add_foreign_key "vtex_products", "vtex_brands", column: "brand_id"
  add_foreign_key "vtex_states", "vtex_countries", column: "country_id"
  add_foreign_key "vtex_transactions", "vtex_orders", column: "order_id"
end
