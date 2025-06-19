# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:internal_code) { |n| "INT#{n}" }
    sequence(:original_title) { |n| "Original Title #{n}" }
    sequence(:title_mx) { |n| "Product #{n}" }
    language { 'Chatino' }
    language_zone { 'Zona alta occidental' }
    edition_number { '1' }
    pages_number { '100' }
    price_mx { 250 }
    stock { 10 }
  end
end
