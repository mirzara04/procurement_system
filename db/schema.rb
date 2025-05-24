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

ActiveRecord::Schema[8.0].define(version: 2025_05_21_230803) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "sku"
    t.decimal "unit_price"
    t.integer "quantity"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string "order_number"
    t.bigint "vendor_id", null: false
    t.decimal "total_amount"
    t.string "status"
    t.datetime "order_date"
    t.datetime "delivery_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_purchase_orders_on_vendor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.boolean "approver"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendor_documents", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.string "document_type"
    t.string "document_number"
    t.date "issue_date"
    t.date "expiry_date"
    t.text "description"
    t.string "status"
    t.bigint "uploaded_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_number"], name: "index_vendor_documents_on_document_number"
    t.index ["status"], name: "index_vendor_documents_on_status"
    t.index ["uploaded_by_id"], name: "index_vendor_documents_on_uploaded_by_id"
    t.index ["vendor_id", "document_type"], name: "index_vendor_documents_on_vendor_id_and_document_type"
    t.index ["vendor_id"], name: "index_vendor_documents_on_vendor_id"
  end

  create_table "vendor_ratings", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.bigint "user_id", null: false
    t.bigint "purchase_order_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.string "category"
    t.datetime "rating_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_order_id"], name: "index_vendor_ratings_on_purchase_order_id"
    t.index ["user_id"], name: "index_vendor_ratings_on_user_id"
    t.index ["vendor_id", "purchase_order_id"], name: "index_vendor_ratings_on_vendor_id_and_purchase_order_id", unique: true
    t.index ["vendor_id"], name: "index_vendor_ratings_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "vendors"
  add_foreign_key "vendor_documents", "users", column: "uploaded_by_id"
  add_foreign_key "vendor_documents", "vendors"
  add_foreign_key "vendor_ratings", "purchase_orders"
  add_foreign_key "vendor_ratings", "users"
  add_foreign_key "vendor_ratings", "vendors"
end
