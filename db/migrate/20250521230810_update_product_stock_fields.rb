class UpdateProductStockFields < ActiveRecord::Migration[8.0]
  def change
    # First rename the existing quantity_in_stock to current_stock
    rename_column :products, :quantity_in_stock, :current_stock
    
    # Then add the new stock-related fields
    add_column :products, :reorder_point, :integer
    add_column :products, :minimum_order_quantity, :integer
    
    # Add an index on current_stock since we'll be querying it frequently
    add_index :products, :current_stock
  end
end 