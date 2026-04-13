class AddTotalAmountToPurchaseOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_order_items, :total_amount, :decimal
  end
end
