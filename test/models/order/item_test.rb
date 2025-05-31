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

      test 'validates presence of price' do
        item.price = nil

        assert item.invalid?
      end
    end
  end
end
