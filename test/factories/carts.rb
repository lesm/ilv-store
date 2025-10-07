# frozen_string_literal: true

FactoryBot.define do
  factory :cart do
    user { association :user }
  end

  trait :with_items do
    after(:create) do |cart|
      create(:label_price, :zero_to_five_kg)
      create_list(:cart_item, 2, cart:)
    end
  end
end
