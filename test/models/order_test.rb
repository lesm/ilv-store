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

    test 'validates inclusion of workflow_status' do
      %w[created in_transit canceled delivered].each do |status|
        order.workflow_status = status
        assert order.valid?
      end

      assert_raises ArgumentError do
        order.workflow_status = 'invalid_status'
      end
    end

    test 'validates inclusion of payment_status' do
      %w[pending paid failed].each do |status|
        order.payment_status = status
        assert order.valid?
      end

      assert_raises ArgumentError do
        order.payment_status = 'invalid_status'
      end
    end
  end
end
