class FixStockColumns < ActiveRecord::Migration[8.0]
  def change
    # First remove the current_stock column that was just added
    remove_column :products, :current_stock
    
    # Then rename quantity_in_stock to current_stock
    rename_column :products, :quantity_in_stock, :current_stock
  end
end 