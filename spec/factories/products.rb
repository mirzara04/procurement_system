FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    sku { "MyString" }
    unit_price { "9.99" }
    quantity { 1 }
    category { "MyString" }
  end
end
