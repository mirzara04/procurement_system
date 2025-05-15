class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_orders do |t|
      t.string :po_number, null: false
      t.references :vendor, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount, precision: 15, scale: 2, default: 0
      t.integer :status, default: 0  # 0 is draft
      t.datetime :order_date
      t.datetime :expected_delivery_date
      t.datetime :actual_delivery_date
      t.text :notes
      t.text :terms_and_conditions
      t.string :shipping_address
      t.string :billing_address
      t.string :payment_terms
      t.references :approved_by, null: true, foreign_key: { to_table: :users }
      t.datetime :approved_at

      t.timestamps
    end

    add_index :purchase_orders, :po_number, unique: true
    add_index :purchase_orders, :status
  end
end
