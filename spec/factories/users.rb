# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| Faker::Internet.email("user_#{n}") }

    password "password"
    password_confirmation { password }

    trait :with_facebook_account do
      provider "facebook"
      sequence(:uid) { |n| "#{provider}-user-#{n}" }
    end

    trait :with_twitter_account do
      provider "twitter"
      sequence(:uid) { |n| "#{provider}-user-#{n}" }
    end

    trait :already_signed_in do
      last_sign_in_at Date.new
      last_sign_in_ip { Faker::Internet.ip_v4_address }
    end
  end

  factory :admin, parent: :user do
    after(:create) { |user| user.grant :admin }
  end
end
