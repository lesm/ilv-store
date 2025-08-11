# frozen_string_literal: true

require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  let(:item) { build(:cart_item) }

  test 'builds a valid cart item' do
    assert item.valid?
  end

  describe '#quantity' do
    test 'valid when is greater than 0' do
      item.quantity = 2
      assert item.valid?
    end

    test 'invalid when is less than 1' do
      item.quantity = 0
      assert item.invalid?
    end
  end

  describe '#stock_availability' do
    let(:product) { create(:product, stock: 5) }

    before do
      item.product = product
    end

    test 'valid when stock is sufficient' do
      item.quantity = 3
      assert item.valid?
    end

    test 'invalid when stock is insufficient' do
      item.quantity = 10
      assert item.invalid?
      assert_includes item.errors[:quantity], 'Solo quedan 5 disponibles.'
    end
  end
end
