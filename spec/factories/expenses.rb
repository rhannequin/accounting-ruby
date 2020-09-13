# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    reason { Faker::Commerce.product_name }
    price { Faker::Commerce.price }
    date { Faker::Date.backward(days: 2) }
  end
end
