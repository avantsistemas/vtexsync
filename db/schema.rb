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

ActiveRecord::Schema.define(version: 2020_10_19_120024) do

  create_table "vtex_clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "vtex_code"
    t.string "first_name"
    t.string "last_name"
    t.string "document_type"
    t.string "document"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vtex_code"], name: "index_vtex_clients_on_vtex_code", unique: true
  end

  create_table "vtex_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "vtex_code"
    t.integer "sequence"
    t.string "status"
    t.string "status_description"
    t.decimal "value", precision: 8, scale: 2
    t.datetime "creation_date"
    t.datetime "last_change"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_vtex_orders_on_client_id"
    t.index ["vtex_code"], name: "index_vtex_orders_on_vtex_code", unique: true
  end

  add_foreign_key "vtex_orders", "vtex_clients", column: "client_id"
end
