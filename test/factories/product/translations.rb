# frozen_string_literal: true

FactoryBot.define do
  factory :product_translation, class: 'Product::Translation' do
    product { association :product }

    locale { 'es' }
    sequence(:title) { |n| "Título en español #{n}" }
    sequence(:subtitle) { |n| "Cha' Su'we nu nchkwi' #{n}" }
    price { 250 }
  end

  trait :en do
    locale { 'en' }
    sequence(:title) { |n| "Title in English #{n}" }
    sequence(:subtitle) { |n| "The quick brown fox jumps over the lazy dog #{n}" }
    price { 30 }
  end

  trait :es do
    locale { 'es' }
    sequence(:title) { |n| "Título en español #{n}" }
    sequence(:subtitle) { |n| "Cha' Su'we nu nchkwi' #{n}" }
    price { 250 }
  end
end
