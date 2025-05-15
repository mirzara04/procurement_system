class CreateVendorDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_documents do |t|
      t.references :vendor, null: false, foreign_key: true
      t.string :document_type  # registration, tax, certification, contract, etc.
      t.string :document_number
      t.date :issue_date
      t.date :expiry_date
      t.text :description
      t.string :status  # active, expired, pending
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :vendor_documents, [:vendor_id, :document_type]
    add_index :vendor_documents, :document_number
    add_index :vendor_documents, :status
  end
end 