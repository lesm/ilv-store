# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:original_title) { |n| "Original Title #{n}" }
    sequence(:title_mx) { |n| "Product #{n}" }
    price_mx { 250 }
    stock { 10 }

    productable { association :book, product: instance }
  end
end
