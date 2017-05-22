FactoryGirl.define do
  factory :expense do
    reason { Faker::Commerce.product_name }
    price { Faker::Commerce.price }
    date { Faker::Date.backward(2) }
  end
end
