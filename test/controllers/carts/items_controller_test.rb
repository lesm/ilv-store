# frozen_string_literal: true

require 'test_helper'

module Carts
  class ItemsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :with_cart) }
    let(:product) { create(:book).product }

    before do
      authenticate_as(user)
    end

    describe '#create' do
      let(:params) do
        { cart_item: { product_id: product.id, quantity: 1 } }
      end

      test 'returns success response' do
        post(cart_items_url(format: :turbo_stream), params:)

        assert_response(:success)
      end

      test 'adds an item to the cart' do
        post(cart_items_url, params:)

        assert user.cart.items.exists?(product_id: product.id)
      end

      test 'increases quantity of an existing item' do
        item = user.cart.items.create(product:, quantity: 1)

        post cart_items_url, params: { cart_item: { product_id: product.id, quantity: 2 } }

        assert_equal(3, item.reload.quantity)
      end

      test 'appends the new cart item' do
        post(cart_items_url(format: :turbo_stream), params:)

        assert_select 'turbo-stream[action="append"]', count: 1
      end

      test 'when product is out of stock' do
        product.update(stock: 0)

        post(cart_items_url(locale: :en, format: :turbo_stream), params:)

        assert_response :unprocessable_content
        assert_includes @response.body, 'The product is out of stock.'
      end
    end

    describe '#update' do
      let(:item) { user.cart.items.create(product:, quantity: 1) }

      test 'returns success response' do
        patch cart_item_url(id: item.id, format: :turbo_stream), params: { cart_item: { quantity: 2 } }

        assert_response(:success)
      end

      test 'updates the item quantity' do
        patch cart_item_url(id: item.id), params: { cart_item: { quantity: 2 } }

        assert_equal(2, item.reload.quantity)
      end
    end

    describe '#destroy' do
      let(:item) { user.cart.items.create(product:) }

      test 'returns success response' do
        delete cart_item_url(id: item.id, format: :turbo_stream)

        assert_response :success
      end

      test 'removes an item from the cart' do
        delete cart_item_url(id: item.id)

        assert_not user.cart.items.exists?(item.id)
      end
    end
  end
end
