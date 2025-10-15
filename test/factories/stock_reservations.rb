# frozen_string_literal: true

FactoryBot.define do
  factory :stock_reservation do
    order { association :order }
    product { association :product }
    quantity { 2 }
    reserved_until { 15.minutes.from_now }
    status { 'active' }

    trait :active do
      status { 'active' }
      reserved_until { 15.minutes.from_now }
    end

    trait :committed do
      status { 'committed' }
    end

    trait :expired do
      status { 'expired' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :expired_time do
      status { 'active' }
      reserved_until { 1.hour.ago }
    end
  end
end
