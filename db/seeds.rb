# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

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
  Vendor.create!(vendor_data)
end

# Create sample products
products = [
  {
    name: 'Laptop Computer',
    description: 'High-performance business laptop',
    sku: 'LAP-001',
    unit_price: 999.99,
    quantity: 50,
    category: 'Electronics'
  },
  {
    name: 'Office Desk',
    description: 'Ergonomic office desk',
    sku: 'DESK-001',
    unit_price: 299.99,
    quantity: 25,
    category: 'Furniture'
  },
  {
    name: 'Printer Paper',
    description: 'A4 printer paper, 500 sheets',
    sku: 'PAP-001',
    unit_price: 5.99,
    quantity: 1000,
    category: 'Office Supplies'
  }
]

products.each do |product_data|
  Product.create!(product_data)
end

puts "Seed data created successfully!"
puts "Admin user created with:"
puts "Email: admin@example.com"
puts "Password: password123"
