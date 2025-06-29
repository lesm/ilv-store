# frozen_string_literal: true

FactoryBot.define do
  factory :cart_item, class: 'Cart::Item' do
    product { association(:product) }
    cart { association :cart }
    quantity { 1 }
    price { product.translation.price }
  end
end
