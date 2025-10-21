# frozen_string_literal: true

require 'test_helper'

class Order
  class ItemTest < ActiveSupport::TestCase
    let(:item) { build(:order_item) }

    test 'builds a valid order item' do
      assert item.valid?
    end

    describe '#validations' do
      test 'validates presence of quantity' do
        item.quantity = nil

        assert item.invalid?
      end

      test 'validates presence of price_mxn and price_usd' do
        item.price_mxn = nil
        item.price_usd = nil

        assert item.invalid?
        assert item.errors[:price_mxn].present?
        assert item.errors[:price_usd].present?
      end
    end
  end
end
