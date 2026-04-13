class AddRolesToUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.boolean :admin, default: false
      t.boolean :approver, default: false
      t.boolean :procurement_officer, default: false
      t.string :name
      t.timestamps null: false

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end unless table_exists?(:users)

    # Add columns if table exists but columns don't
    reversible do |dir|
      dir.up do
        unless table_exists?(:users)
          add_column :users, :admin, :boolean, default: false
          add_column :users, :approver, :boolean, default: false
          add_column :users, :procurement_officer, :boolean, default: false
          add_column :users, :name, :string
        end
      end
    end
  end
end
