# frozen_string_literal: true

require 'test_helper'

class CartTest < ActiveSupport::TestCase
  let(:cart) { create(:cart) }

  test 'builds a valid cart' do
    assert build(:cart).valid?
  end

  describe '#total_price' do
    test 'calculates the total price of the cart' do
      translation = build(:product_translation, locale: :es, price: 10)
      cart.items << build(:cart_item, product: build(:product, translations: [translation]), quantity: 2)
      translation = build(:product_translation, locale: :es, price: 5)
      cart.items << build(:cart_item, product: build(:product, translations: [translation]), quantity: 1)

      assert_equal 25, cart.total_price
    end
  end
end
