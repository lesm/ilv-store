# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    user { association :user }
    address { association :address, :oxxo_bustamante }
    subtotal { 100.00 }
    total { 100.00 }
    workflow_status { 'created' }
  end

  # :created for some reason can not be used as a trait name
  trait :order_created do
    before(:create) do |order|
      order.items << build_list(:order_item, 2)
    end

    workflow_status { 'created' }
  end
end
