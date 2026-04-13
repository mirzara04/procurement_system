class CreateVendorRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_ratings do |t|
      t.decimal :rating
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.references :purchase_order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
