# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    stock { 10 }

    translations { [build(:product_translation, product: instance)] }
    productable { association :book, product: instance }
  end
end
