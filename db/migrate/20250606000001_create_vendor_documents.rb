class CreateVendorDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_documents do |t|
      t.references :vendor, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.string :document_type, null: false
      t.string :document_number, null: false
      t.string :status, default: 'active', null: false
      t.date :issue_date
      t.date :expiry_date
      t.text :notes

      t.timestamps
    end

    add_index :vendor_documents, [:vendor_id, :document_number], unique: true
    add_index :vendor_documents, :status
    add_index :vendor_documents, :expiry_date
  end
end
