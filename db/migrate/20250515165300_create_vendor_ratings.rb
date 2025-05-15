class CreateVendorRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_ratings do |t|
      t.references :vendor, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :purchase_order, null: false, foreign_key: true
      t.integer :rating, null: false  # 1-5 scale
      t.text :comment
      t.string :category  # quality, delivery, price, service, etc.
      t.datetime :rating_date

      t.timestamps
    end

    add_index :vendor_ratings, [:vendor_id, :purchase_order_id], unique: true
  end
end 