FactoryBot.define do
  factory :purchase_order_item do
    purchase_order { nil }
    product { nil }
    quantity { 1 }
    unit_price { "9.99" }
    total_price { "9.99" }
  end
end
