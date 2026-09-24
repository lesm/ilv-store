# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  let(:product) { build(:product) }

  test 'builds a valid product' do
    assert product.valid?
  end

  describe '#validations' do
    test 'validates stock greater than 0' do
      product.stock = -5

      assert product.invalid?
    end

    test 'validates cover image type' do
      product.cover.attach(io: Rails.root.join('test/fixtures/files/cover.webp').open,
                           filename: 'cover.webp', content_type: 'image/webp')

      assert product.invalid?
      assert_includes product.errors[:cover], 'no es válida: debe ser JPG, JPEG o PNG.'
    end
  end

  describe 'publishing' do
    let(:published_product) { create(:product) }
    let(:unpublished_product) { create(:product, :unpublished) }

    test 'is published by default' do
      assert_predicate Product.new, :published?
    end

    test '.published returns only published products' do
      assert_equal [published_product], Product.published.where(id: [published_product, unpublished_product])
    end

    test '.unpublished returns only unpublished products' do
      assert_equal [unpublished_product], Product.unpublished.where(id: [published_product, unpublished_product])
    end

    test '#publish! publishes the product' do
      unpublished_product.publish!

      assert_predicate unpublished_product.reload, :published?
    end

    test '#unpublish! unpublishes the product' do
      published_product.unpublish!

      assert_not_predicate published_product.reload, :published?
    end

    test 'reindexes the product in Typesense' do
      published_product.expects(:index_in_typesense)

      published_product.unpublish!
    end
  end
end
