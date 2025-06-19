# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  let(:product) { build(:product) }

  test 'builds a valid product' do
    assert product.valid?
  end

  describe '#validations' do
    test 'validates presence of original_title' do
      product.original_title = nil

      assert product.invalid?
    end

    test 'validates presence of title_mx' do
      product.title_mx = nil

      assert product.invalid?
    end

    test 'validates presence of language' do
      product.language = nil

      assert product.invalid?
    end

    test 'validates presence of language_zone' do
      product.language_zone = nil

      assert product.invalid?
    end

    test 'validates presence of edition_number' do
      product.edition_number = nil

      assert product.invalid?
    end

    test 'validates presence of pages_number' do
      product.pages_number = nil

      assert product.invalid?
    end

    test 'validates presence of internal_code' do
      product.internal_code = nil

      assert product.invalid?
    end

    test 'validates presence of price_mx' do
      product.price_mx = nil

      assert product.invalid?
    end

    test 'validates presence of stock' do
      product.stock = nil

      assert product.invalid?
    end

    test 'validates numericality greater than 0 for price_mx' do
      product.price_mx = -10

      assert product.invalid?
    end

    test 'validates numericality greater than 0 for stock' do
      product.stock = -5

      assert product.invalid?
    end

    test 'validates uniqueness of internal_code' do
      existing_product = create(:product, internal_code: 'UNIQUE123')
      product.internal_code = existing_product.internal_code

      assert product.invalid?
    end
  end
end
