# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    stock { 10 }
    reserved_stock { 0 }
    translations do
      [build(:product_translation, :en, product: instance), build(:product_translation, :es, product: instance)]
    end
    productable { association :book, product: instance }
  end
end
