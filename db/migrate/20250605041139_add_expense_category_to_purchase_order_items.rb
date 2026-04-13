class AddExpenseCategoryToPurchaseOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_order_items, :expense_category, :string
  end
end
