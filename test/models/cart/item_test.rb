# frozen_string_literal: true

require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  let(:cart_item) { build(:cart_item) }

  test 'builds a valid cart item' do
    assert cart_item.valid?
  end

  describe '#quantity' do
    test 'valid when is greater than 0' do
      cart_item.quantity = 2
      assert cart_item.valid?
    end

    test 'invalid when is less than 1' do
      cart_item.quantity = 0
      assert cart_item.invalid?
    end
  end
end
