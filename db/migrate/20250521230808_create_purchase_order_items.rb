class CreatePurchaseOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 15, scale: 2, null: false
      t.decimal :total_price, precision: 15, scale: 2, null: false
      t.text :description
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :purchase_order_items, [:purchase_order_id, :product_id]
  end
end 