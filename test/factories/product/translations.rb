# frozen_string_literal: true

FactoryBot.define do
  factory :product_translation, class: 'Product::Translation' do
    product { association :product }

    locale { 'es' }
    sequence(:title) { |n| "Título en español #{n}" }
    sequence(:subtitle) { |n| "Cha' Su'we nu nchkwi' #{n}" }
    price { 250 }
  end
end
