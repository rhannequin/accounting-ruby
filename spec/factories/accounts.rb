FactoryGirl.define do
  factory :account do
    name { Faker::Bank.name }
  end
end
