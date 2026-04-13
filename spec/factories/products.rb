FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:sku) { |n| "SKU-#{n}" }
    description { "A test product description" }
    unit_price { 99.99 }
    current_stock { 100 }
    reorder_point { 20 }
    minimum_order_quantity { 10 }
    category { :electronics }
    status { :active }

    trait :active do
      status { :active }
      current_stock { 100 }
    end

    trait :discontinued do
      status { :discontinued }
      current_stock { 0 }
    end

    trait :out_of_stock do
      status { :out_of_stock }
      current_stock { 0 }
    end

    trait :low_stock do
      current_stock { 5 }
      reorder_point { 10 }
    end

    trait :with_vendor do
      association :vendor, factory: [:vendor, :active]
    end
  end
end
