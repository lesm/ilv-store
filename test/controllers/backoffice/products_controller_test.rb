# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :admin) }
    let(:book) { create(:book) }
    let(:product) { book.product }

    let(:params) do
      {
        type: 'book',
        book: {
          internal_code: '12345',
          language: 'Spanish',
          language_zone: 'MX',
          edition_number: '100',
          pages_number: '1000',
          cover_color: 'White',
          dimensions: '19.05 x 1.73 x 23.5 cm',
          weight_grams: 250,
          product_attributes: {
            stock: 50,
            cover: fixture_file_upload('test/fixtures/files/book.png', 'image/png'),
            translations_attributes: [
              {
                title: 'Test Product',
                subtitle: 'Producto de Prueba',
                locale: 'es',
                price: 99.99
              }
            ]
          }
        }
      }
    end

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns success response' do
        create_list(:book, 3)

        get backoffice_products_url(type: 'book')
        assert_response :success
      end
    end

    describe '#GET new' do
      test 'returns success response' do
        get new_backoffice_product_url(type: 'book', turbo_frame: 'drawer')
        assert_response :success
      end
    end

    describe '#GET edit' do
      test 'returns success response' do
        get edit_backoffice_product_url(id: book.id, type: 'book', turbo_frame: 'drawer')
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
          params[:book][:internal_code] = nil
          post(backoffice_products_url(format: :turbo_stream), params:)

          assert_turbo_stream action: :append, target: 'flash'
        end
      end
    end

    describe '#PATCH update' do
      describe 'with valid params' do
        let(:es_translation) { product.translations.find { |t| t.locale == 'es' } }

        before do
          params[:book][:product_attributes][:id] = product.id
          params[:book][:product_attributes][:translations_attributes] = {
            0 => {
              id: es_translation.id,
              title: 'Test Product',
              subtitle: 'Producto de Prueba',
              locale: 'es',
              price: 99.99
            }
          }
        end

        test 'redirects to the backoffice products page' do
          put(backoffice_product_url(id: book.id, format: :turbo_stream), params:)

          assert_redirected_to backoffice_products_path
        end

        test 'updates the product' do
          put(backoffice_product_url(id: book.id, format: :turbo_stream), params:)

          book.reload
          product.reload
          assert_equal '12345', book.internal_code
          assert_equal 'Spanish', book.language
          assert_equal 'MX', book.language_zone
          assert_equal '100', book.edition_number
          assert_equal '1000', book.pages_number

          assert_equal 'Test Product', product.title
          assert_equal 'Producto de Prueba', product.subtitle
          assert_equal 99.99, product.price
          assert_equal 50, product.stock
          assert_equal 'book.png', product.cover.blob.filename.to_s
        end
      end

      describe 'with invalid params' do
        test 'returns unprocessable entity status' do
          params[:book][:product_attributes][:translations_attributes][0][:price] = nil
          put(backoffice_product_url(id: book.id, format: :turbo_stream), params:)

          assert_response :unprocessable_entity
        end

        test 'does not update the product' do
          original_price = product.price
          params[:book][:product_attributes][:translations_attributes][0][:price] = nil
          put(backoffice_product_url(id: book.id, format: :turbo_stream), params:)

          assert_equal original_price, product.reload.price
        end
      end
    end
  end
end
