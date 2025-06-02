# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    after(:build) do |user|
      user.country ||= Country.find_or_create_by(name: 'México', code: 'MX')
    end

    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    theme_preference { 'light' }
    verified { true }
  end

  trait :with_cart do
    cart { association(:cart, :with_items) }
  end

  trait :with_default_address do
    after(:create) do |user|
      create(:address, :mx, user: user, default: true)
    end
  end
end
