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

    test 'validates cover image type' do
      product.cover.attach(io: File.open(Rails.root.join('test/fixtures/files/cover.webp')),
                           filename: 'cover.webp', content_type: 'image/webp')

      assert product.invalid?
      assert_includes product.errors[:cover], 'no es válida: debe ser JPG, JPEG o PNG.'
    end
  end
end
