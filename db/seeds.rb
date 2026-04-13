# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample products first
products = [
  {
    name: 'Laptop Computer',
    description: 'High-performance business laptop',
    sku: 'LAP-001',
    unit_price: 999.99,
    category: :electronics,
    current_stock: 50,
    reorder_point: 10,
    minimum_order_quantity: 5,
    status: :active
  },
  {
    name: 'Office Desk',
    description: 'Ergonomic office desk',
    sku: 'DESK-001',
    unit_price: 299.99,
    category: :furniture,
    current_stock: 25,
    reorder_point: 5,
    minimum_order_quantity: 2,
    status: :active
  },
  {
    name: 'Printer Paper',
    description: 'A4 printer paper, 500 sheets',
    sku: 'PAP-001',
    unit_price: 5.99,
    category: :office_supplies,
    current_stock: 1000,
    reorder_point: 200,
    minimum_order_quantity: 50,
    status: :active
  }
]

# Create products if they don't exist
products.each do |product_data|
  Product.find_or_create_by!(sku: product_data[:sku]) do |product|
    product.assign_attributes(product_data)
  end
end

# Create admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'System Administrator'
  user.admin = true
  user.approver = true
end

# Create a procurement officer
User.find_or_create_by!(email: 'procurement@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Procurement Officer'
  user.procurement_officer = true
end

# Create an approver
User.find_or_create_by!(email: 'approver@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Approver'
  user.approver = true
end

# Test users with different departments - ensure unique department emails
departments = {
  'IT' => 'it.dept@example.com',
  'HR' => 'hr.dept@example.com',
  'Finance' => 'finance.dept@example.com',
  'Operations' => 'ops.dept@example.com',
  'Unassigned' => 'unassigned.dept@example.com'
}

departments.each do |dept_name, email|
  User.find_or_create_by!(email: email) do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.department = dept_name == 'Unassigned' ? nil : dept_name
    user.admin = true # Making them admin so they can access reports
    user.name = "#{dept_name} Manager"
  end
end

# Create some vendors
vendor = Vendor.find_or_create_by!(email: 'vendor@example.com') do |v|
  v.name = 'Test Vendor'
  v.status = 'active'
  v.phone = '555-0100'
  v.address = '100 Vendor Street, Business District'
end

# Create purchase orders for each user with different amounts
User.all.each do |user|
  # Only create purchase orders for users that don't have any
  next if user.created_purchase_orders.exists?
  
  3.times do |i|
    # Get available products
    available_products = Product.all.to_a
    
    # Prepare items first
    items_attributes = []
    rand(2..3).times do
      product = available_products.sample
      item_amount = product.unit_price * rand(1..10)
      items_attributes << {
        product_id: product.id,  # Use product_id instead of product
        quantity: rand(1..10),
        unit_price: product.unit_price  # Use product's unit price
      }
    end

    # Calculate total amount from items
    total_amount = items_attributes.sum { |item| item[:quantity] * item[:unit_price] }

    # Create purchase order with items in a transaction
    ActiveRecord::Base.transaction do
      po = PurchaseOrder.new(
        vendor: vendor,
        created_by: user,
        status: 'approved',
        total_amount: total_amount,
        approved_at: Time.current,
        expected_delivery_date: 30.days.from_now,
        po_number: "PO-#{user.id}-#{Time.current.to_i}-#{i}",
        shipping_address: "#{user.department || 'Main'} Department, 123 Business Ave, Suite #{100 + i}"
      )

      # Create items directly with the purchase order
      items_attributes.each do |item_attrs|
        po.purchase_order_items.build(item_attrs)
      end

      # Save the purchase order with its items
      po.save!
    end
  end
end

# Create sample vendors
vendors = [
  {
    name: 'Tech Solutions Inc.',
    email: 'sales@techsolutions.com',
    phone: '555-0123',
    address: '123 Tech Street, Silicon Valley, CA',
    status: 'active'
  },
  {
    name: 'Office Supplies Co.',
    email: 'orders@officesupplies.com',
    phone: '555-0124',
    address: '456 Supply Road, Business District',
    status: 'active'
  }
]

vendors.each do |vendor_data|
  Vendor.find_or_create_by!(email: vendor_data[:email]) do |vendor|
    vendor.assign_attributes(vendor_data)
  end
end

puts "Seed data created successfully!"
puts "\nDefault Users Created:"
puts "1. Administrator"
puts "   Email: admin@example.com"
puts "   Password: password123"
puts "\n2. Procurement Officer"
puts "   Email: procurement@example.com"
puts "   Password: password123"
puts "\n3. Approver"
puts "   Email: approver@example.com"
puts "   Password: password123"
