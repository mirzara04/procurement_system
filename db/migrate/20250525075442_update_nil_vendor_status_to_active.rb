class UpdateNilVendorStatusToActive < ActiveRecord::Migration[8.0]
  def up
    # Update all vendors with nil status to 'active'
    execute <<-SQL
      UPDATE vendors 
      SET status = 'active' 
      WHERE status IS NULL;
    SQL

    # Set default value for status column if not already set
    change_column_default :vendors, :status, 'active'
    change_column_null :vendors, :status, false, 'active'
  end

  def down
    change_column_null :vendors, :status, true
    change_column_default :vendors, :status, nil
  end
end
