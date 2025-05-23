# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    theme_preference { 'light' }
    verified { true }
  end

  trait :with_cart do
    cart { association(:cart) }
  end

  trait :with_default_address do
    after(:create) do |user|
      create(:mexican_address, user: user, default: true)
    end
  end
end
