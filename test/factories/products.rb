# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    stock { 10 }
    translations do
      [build(:product_translation, :en, product: instance), build(:product_translation, :es, product: instance)]
    end
    productable { association :book, product: instance }
  end
end
