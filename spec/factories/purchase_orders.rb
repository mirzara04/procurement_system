FactoryBot.define do
  factory :purchase_order do
    order_number { "MyString" }
    vendor { nil }
    total_amount { "9.99" }
    status { "MyString" }
    order_date { "2025-05-15 09:51:18" }
    delivery_date { "2025-05-15 09:51:18" }
  end
end
