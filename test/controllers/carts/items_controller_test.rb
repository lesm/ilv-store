# frozen_string_literal: true

require 'test_helper'

module Carts
  class ItemsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user) }
    let(:product) { create(:product) }

    before do
      authenticate_as(user)
    end

    describe '#create' do
      test 'returns success response' do
        post cart_items_url(format: :turbo_stream), params: { product_id: product.id }

        assert_response :success
      end

      test 'adds an item to the cart' do
        post cart_items_url, params: { product_id: product.id }

        assert_equal(1, user.cart.items.count)
      end
    end

    describe '#destroy' do
      let(:cart) { create(:cart, user:) }
      let(:item) { cart.items.create(product:) }

      test 'returns success response' do
        delete cart_item_url(id: item.id, format: :turbo_stream)

        assert_response :success
      end

      test 'removes an item from the cart' do
        delete cart_item_url(id: item.id)

        assert_equal(0, user.cart.items.count)
      end
    end
  end
end
