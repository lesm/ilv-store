# frozen_string_literal: true

FactoryBot.define do
  factory :label_price do
    product_type { 'book' }
    range_start { '1' }
    range_end { '5' }
    price { '150' }
    unit { 'kg' }
  end
end
