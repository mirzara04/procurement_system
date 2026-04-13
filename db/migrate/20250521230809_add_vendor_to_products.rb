class AddVendorToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :vendor, foreign_key: true, null: true
  end
end 