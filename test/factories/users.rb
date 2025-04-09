# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end

  trait :with_cart do
    cart { association(:cart) }
  end
end
