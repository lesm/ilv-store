# frozen_string_literal: true

FactoryBot.define do
  factory :order_item, class: 'Order::Item' do
    order { association :order }
    product { association :product }
    quantity { 1 }
    price_mxn { 10.00 }
    price_usd { 0.50 }
  end
end
