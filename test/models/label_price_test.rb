# frozen_string_literal: true

require 'test_helper'

class LabelPriceTest < ActiveSupport::TestCase
  test 'build a valid factory' do
    assert build(:label_price).valid?
  end

  test 'presence validations' do
    I18n.with_locale(:en) do
      label_price = LabelPrice.new
      assert_not label_price.valid?
      assert_includes label_price.errors[:product_type], "can't be blank"
      assert_includes label_price.errors[:range_start], "can't be blank"
      assert_includes label_price.errors[:range_end], "can't be blank"
      assert_includes label_price.errors[:price_mxn], "can't be blank"
      assert_includes label_price.errors[:price_usd], "can't be blank"
      assert_includes label_price.errors[:unit], "can't be blank"
    end
  end

  describe '#range_end' do
    test 'must be greater than range_start' do
      I18n.with_locale(:en) do
        label_price = build(:label_price, range_start: 5, range_end: 3)
        assert_not label_price.valid?
        assert_includes label_price.errors[:range_end], 'must be greater than 5.0'
      end
    end
  end
end
