class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.string :sku, null: false
      t.decimal :unit_price, precision: 15, scale: 2
      t.integer :quantity_in_stock, default: 0
      t.integer :minimum_stock_level
      t.string :category
      t.string :unit_of_measure
      t.string :status, default: 'active'
      t.text :notes
      t.string :manufacturer
      t.string :brand

      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :name
    add_index :products, :category
    add_index :products, :status
  end
end 