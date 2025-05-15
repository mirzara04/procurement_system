class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :sku
      t.decimal :unit_price
      t.integer :quantity
      t.string :category

      t.timestamps
    end
  end
end
