class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :address
      t.string :tax_id
      t.string :registration_number
      t.string :status, default: 'active'
      t.text :notes
      t.string :website
      t.string :contact_person
      t.string :contact_position
      t.string :bank_account_details
      t.string :payment_terms
      t.string :currency, default: 'USD'

      t.timestamps
    end

    add_index :vendors, :name
    add_index :vendors, :email
    add_index :vendors, :status
    add_index :vendors, :registration_number, unique: true
  end
end 