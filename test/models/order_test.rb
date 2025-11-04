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
      %w[pending created in_transit canceled delivered].each do |status|
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

    test 'accepts nil tracking_number' do
      order.tracking_number = nil

      assert order.valid?
    end

    test 'rejects empty string tracking_number' do
      I18n.with_locale(:en) do
        order.tracking_number = ''

        assert order.invalid?
        assert_includes order.errors[:tracking_number], "can't be blank"
      end
    end

    test 'accepts non-empty tracking_number' do
      order.tracking_number = 'TRACK123'

      assert order.valid?
    end

    test 'accepts nil carrier_name' do
      order.carrier_name = nil

      assert order.valid?
    end

    test 'rejects empty string carrier_name' do
      I18n.with_locale(:en) do
        order.carrier_name = ''

        assert order.invalid?
        assert_includes order.errors[:carrier_name], "can't be blank"
      end
    end

    test 'accepts non-empty carrier_name' do
      order.carrier_name = 'FedEx'

      assert order.valid?
    end
  end
end
