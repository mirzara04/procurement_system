FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :admin do
      admin { true }
    end

    trait :approver do
      approver { true }
    end

    trait :procurement_officer do
      procurement_officer { true }
    end
  end
end
