class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_orders do |t|
      t.string :po_number, null: false
      t.references :vendor, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }
      t.decimal :total_amount, precision: 15, scale: 2
      t.string :status, null: false, default: 'draft'
      t.datetime :order_date
      t.datetime :expected_delivery_date
      t.datetime :delivery_date
      t.datetime :approved_at
      t.string :shipping_address, null: false
      t.string :payment_terms
      t.string :currency, null: false, default: 'USD'
      t.text :notes

      t.timestamps
    end

    add_index :purchase_orders, :po_number, unique: true
    add_index :purchase_orders, :status
  end
end