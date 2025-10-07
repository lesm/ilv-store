# frozen_string_literal: true

FactoryBot.define do
  factory :label_price do
    product_type { 'Book' }
    range_start { '1' }
    range_end { '5' }
    price { '150' }
    unit { 'kg' }
  end

  trait :cero_to_five_kg do
    product_type { 'Book' }
    range_start { '0' }
    range_end { '5' }
    price { '150' }
  end
end
