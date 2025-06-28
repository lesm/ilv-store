# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  let(:product) { build(:product) }

  test 'builds a valid product' do
    assert product.valid?
  end

  describe '#validations' do
    test 'validates presence of stock' do
      product.stock = nil

      assert product.invalid?
    end

    test 'validates stock greater than 0' do
      product.stock = -5

      assert product.invalid?
    end
  end
end
