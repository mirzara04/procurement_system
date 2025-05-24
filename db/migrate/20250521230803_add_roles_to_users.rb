class AddRolesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :approver, :boolean
    add_column :users, :name, :string
  end
end
