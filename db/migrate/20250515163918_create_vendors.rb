class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.text :address
      t.integer :status, default: 3  # 3 is pending_approval
      t.string :tax_number
      t.text :notes
      t.string :contact_person
      t.string :website
      t.string :registration_number

      t.timestamps
    end

    add_index :vendors, :email, unique: true
    add_index :vendors, :tax_number, unique: true
    add_index :vendors, :status
  end
end
