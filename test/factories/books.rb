# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    sequence(:internal_code) { |n| "INT#{n}" }
    language { 'Chatino' }
    language_zone { 'Zona alta occidental' }
    edition_number { '1' }
    pages_number { '100' }

    after(:build) do |book|
      book.product = build(:product) unless book.product
    end
  end
end
