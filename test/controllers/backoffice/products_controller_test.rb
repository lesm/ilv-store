# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :admin) }
    let(:product) { create(:product) }

    let(:params) do
      {
        product: {
          internal_code: '12345',
          original_title: 'Test Product',
          title_mx: 'Producto de Prueba',
          language: 'Spanish',
          language_zone: 'MX',
          edition_number: '1',
          pages_number: '100',
          price_mx: 99.99,
          stock: 50
        }
      }
    end

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns success response' do
        get backoffice_products_url
        assert_response :success
      end
    end

    describe '#GET new' do
      test 'returns success response' do
        get new_backoffice_product_url(turbo_frame: 'drawer')
        assert_response :success
      end
    end

    describe '#GET edit' do
      test 'returns success response' do
        get edit_backoffice_product_url(id: product.id, turbo_frame: 'drawer')
        assert_response :success
      end
    end

    describe '#POST create' do
      describe 'with valid params' do
        test 'redirects to the backoffice products page' do
          post(backoffice_products_url(format: :turbo_stream), params:)

          assert_turbo_stream action: :redirect
        end
      end

      describe 'with invalid params' do
        test 'redirects to the new backoffice product page' do
          params[:product][:internal_code] = nil
          post(backoffice_products_url(format: :turbo_stream), params:)

          assert_turbo_stream action: :append, target: 'flash'
        end
      end
    end

    describe '#PATCH update' do # rubocop:disable Metrics/BlockLength
      describe 'with valid params' do
        test 'redirects to the backoffice products page' do
          put(backoffice_product_url(id: product.id, format: :turbo_stream), params:)

          assert_turbo_stream action: :redirect
        end

        test 'updates the product' do
          put(backoffice_product_url(id: product.id, format: :turbo_stream), params:)

          product.reload
          assert_equal '12345', product.internal_code
          assert_equal 'Test Product', product.original_title
          assert_equal 'Producto de Prueba', product.title_mx
          assert_equal 'Spanish', product.language
          assert_equal 'MX', product.language_zone
          assert_equal '1', product.edition_number
          assert_equal '100', product.pages_number
          assert_equal 99.99, product.price_mx
          assert_equal 50, product.stock
        end
      end

      describe 'with invalid params' do
        test 'redirects to the edit backoffice product page' do
          params[:product][:price_mx] = nil
          put(backoffice_product_url(id: product.id, format: :turbo_stream), params:)

          assert_turbo_stream action: :append, target: 'flash'
        end

        test 'does not update the product' do
          original_price = product.price_mx
          params[:product][:price_mx] = nil
          put(backoffice_product_url(id: product.id, format: :turbo_stream), params:)

          assert_equal original_price, product.reload.price_mx
        end
      end
    end
  end
end
