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

ActiveRecord::Schema[8.1].define(version: 2026_10_06_151239) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bike_models", force: :cascade do |t|
    t.string "brand", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bikes", force: :cascade do |t|
    t.bigint "bike_model_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "serial_number", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_model_id"], name: "index_bikes_on_bike_model_id"
    t.index ["customer_id"], name: "index_bikes_on_customer_id"
    t.index ["serial_number"], name: "index_bikes_on_serial_number", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "issued_at", null: false
    t.string "number", null: false
    t.bigint "repair_id", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_invoices_on_number", unique: true
    t.index ["repair_id"], name: "index_invoices_on_repair_id", unique: true
  end

  create_table "mechanics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repair_services", force: :cascade do |t|
    t.decimal "charged_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "repair_id", null: false
    t.bigint "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["repair_id"], name: "index_repair_services_on_repair_id"
    t.index ["service_id"], name: "index_repair_services_on_service_id"
  end

  create_table "repairs", force: :cascade do |t|
    t.bigint "bike_id", null: false
    t.datetime "collected_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "finished_at"
    t.bigint "mechanic_id"
    t.date "promised_on", null: false
    t.string "quote_response"
    t.decimal "quoted_amount", precision: 10, scale: 2
    t.datetime "quoted_at"
    t.datetime "received_at", null: false
    t.datetime "responded_at"
    t.string "state", default: "received", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id"], name: "index_repairs_on_bike_id"
    t.index ["customer_id"], name: "index_repairs_on_customer_id"
    t.index ["mechanic_id"], name: "index_repairs_on_mechanic_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bikes", "bike_models"
  add_foreign_key "bikes", "customers"
  add_foreign_key "invoices", "repairs"
  add_foreign_key "repair_services", "repairs"
  add_foreign_key "repair_services", "services"
  add_foreign_key "repairs", "bikes"
  add_foreign_key "repairs", "customers"
  add_foreign_key "repairs", "mechanics"
end
