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

ActiveRecord::Schema[8.0].define(version: 2025_06_06_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "sku", null: false
    t.decimal "unit_price", precision: 15, scale: 2
    t.integer "current_stock", default: 0
    t.integer "minimum_stock_level"
    t.string "category"
    t.string "unit_of_measure"
    t.string "status", default: "active"
    t.text "notes"
    t.string "manufacturer"
    t.string "brand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.integer "reorder_point"
    t.integer "minimum_order_quantity"
    t.index ["category"], name: "index_products_on_category"
    t.index ["name"], name: "index_products_on_name"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 15, scale: 2, null: false
    t.decimal "total_price", precision: 15, scale: 2, null: false
    t.text "description"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expense_category"
    t.decimal "total_amount"
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id", "product_id"], name: "index_purchase_order_items_on_purchase_order_id_and_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string "po_number", null: false
    t.bigint "vendor_id", null: false
    t.bigint "created_by_id", null: false
    t.bigint "approved_by_id"
    t.decimal "total_amount", precision: 15, scale: 2
    t.string "status", default: "draft", null: false
    t.datetime "order_date"
    t.datetime "expected_delivery_date"
    t.datetime "delivery_date"
    t.datetime "approved_at"
    t.string "shipping_address", null: false
    t.string "payment_terms"
    t.string "currency", default: "USD", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_purchase_orders_on_approved_by_id"
    t.index ["created_by_id"], name: "index_purchase_orders_on_created_by_id"
    t.index ["po_number"], name: "index_purchase_orders_on_po_number", unique: true
    t.index ["status"], name: "index_purchase_orders_on_status"
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
    t.string "department"
    t.index ["department"], name: "index_users_on_department"
  end

  create_table "vendor_documents", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.bigint "uploaded_by_id", null: false
    t.string "document_type", null: false
    t.string "document_number", null: false
    t.string "status", default: "active", null: false
    t.date "issue_date"
    t.date "expiry_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiry_date"], name: "index_vendor_documents_on_expiry_date"
    t.index ["status"], name: "index_vendor_documents_on_status"
    t.index ["uploaded_by_id"], name: "index_vendor_documents_on_uploaded_by_id"
    t.index ["vendor_id", "document_number"], name: "index_vendor_documents_on_vendor_id_and_document_number", unique: true
    t.index ["vendor_id"], name: "index_vendor_documents_on_vendor_id"
  end

  create_table "vendor_ratings", force: :cascade do |t|
    t.decimal "rating"
    t.text "comment"
    t.bigint "user_id", null: false
    t.bigint "vendor_id", null: false
    t.bigint "purchase_order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_order_id"], name: "index_vendor_ratings_on_purchase_order_id"
    t.index ["user_id"], name: "index_vendor_ratings_on_user_id"
    t.index ["vendor_id"], name: "index_vendor_ratings_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.text "address"
    t.string "tax_id"
    t.string "registration_number"
    t.string "status", default: "active", null: false
    t.text "notes"
    t.string "website"
    t.string "contact_person"
    t.string "contact_position"
    t.string "bank_account_details"
    t.string "payment_terms"
    t.string "currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_vendors_on_email"
    t.index ["name"], name: "index_vendors_on_name"
    t.index ["registration_number"], name: "index_vendors_on_registration_number", unique: true
    t.index ["status"], name: "index_vendors_on_status"
  end

  add_foreign_key "products", "vendors"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "users", column: "approved_by_id"
  add_foreign_key "purchase_orders", "users", column: "created_by_id"
  add_foreign_key "purchase_orders", "vendors"
  add_foreign_key "vendor_documents", "users", column: "uploaded_by_id"
  add_foreign_key "vendor_documents", "vendors"
  add_foreign_key "vendor_ratings", "purchase_orders"
  add_foreign_key "vendor_ratings", "users"
  add_foreign_key "vendor_ratings", "vendors"
end
