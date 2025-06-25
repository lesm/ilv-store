# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  let(:order) { build(:order) }

  test 'builds a valid order' do
    assert order.valid?
  end

  describe '#validations' do
    test 'validates presence of subtotal' do
      order.subtotal = nil

      assert order.invalid?
    end

    test 'validates presence of total' do
      order.total = nil

      assert order.invalid?
    end

    test 'raises an error for an unknown status' do
      assert_raises ArgumentError do
        order.workflow_status = 'unknown_status'
      end
    end
  end
end
