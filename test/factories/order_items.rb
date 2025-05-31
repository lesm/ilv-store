# frozen_string_literal: true

FactoryBot.define do
  factory :order_item, class: 'Order::Item' do
    order { association :order }
    product { association :product }
    quantity { 1 }
    price { 10.00 }
  end
end
