# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    user { association :user }
    address { association :address, :mx }
    subtotal { 100.00 }
    total { 100.00 }
  end
end
