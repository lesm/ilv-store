# frozen_string_literal: true

require 'test_helper'

class CartTest < ActiveSupport::TestCase
  let(:cart) { create(:cart) }

  test 'builds a valid cart' do
    assert build(:cart).valid?
  end

  describe '#total_price' do
    test 'calculates the total price of the cart' do
      cart.items << build(:cart_item, product: build(:product, price_mx: 10), quantity: 2)
      cart.items << build(:cart_item, product: build(:product, price_mx: 5), quantity: 1)

      assert_equal 25, cart.total_price
    end
  end
end
