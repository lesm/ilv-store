# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class LabelPricesControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :admin) }
    let(:label_price) { create(:label_price) }

    let(:valid_params) do
      {
        label_price: {
          product_type: 'Book',
          range_start: 1,
          range_end: 10,
          price_mxn: 100.0,
          price_usd: 7.0,
          unit: 'kg'
        }
      }
    end

    let(:invalid_params) do
      {
        label_price: {
          product_type: 'Book',
          range_start: 10,
          range_end: 1,
          price_mxn: 100.0,
          price_usd: 7.0,
          unit: 'kg'
        }
      }
    end

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns success response' do
        create_list(:label_price, 3)

        get backoffice_label_prices_url
        assert_response :success
      end
    end

    describe '#GET new' do
      test 'returns success response' do
        get new_backoffice_label_price_url(turbo_frame: 'drawer')
        assert_response :success
      end
    end

    describe '#GET edit' do
      test 'returns success response' do
        get edit_backoffice_label_price_url(id: label_price.id, turbo_frame: 'drawer')
        assert_response :success
      end
    end

    describe '#POST create' do
      describe 'with valid params' do
        test 'redirects to the backoffice label prices page' do
          post(backoffice_label_prices_url(format: :turbo_stream), params: valid_params)

          assert_turbo_stream action: :redirect
        end

        test 'creates a new label price' do
          assert_difference('LabelPrice.count', 1) do
            post(backoffice_label_prices_url(format: :turbo_stream), params: valid_params)
          end

          label_price = LabelPrice.last
          assert_equal 'Book', label_price.product_type
          assert_equal 1, label_price.range_start
          assert_equal 10, label_price.range_end
          assert_equal 100.0, label_price.price_mxn
          assert_equal 7.0, label_price.price_usd
          assert_equal 'kg', label_price.unit
        end
      end

      describe 'with invalid params' do
        test 'appends flash message' do
          post(backoffice_label_prices_url(format: :turbo_stream), params: invalid_params)

          assert_turbo_stream action: :append, target: 'flash'
        end

        test 'does not create a new label price' do
          assert_no_difference('LabelPrice.count') do
            post(backoffice_label_prices_url(format: :turbo_stream), params: invalid_params)
          end
        end
      end
    end

    describe '#PATCH update' do
      describe 'with valid params' do
        test 'redirects to the backoffice label prices page' do
          put(backoffice_label_price_url(id: label_price.id, format: :turbo_stream), params: valid_params)

          assert_turbo_stream action: :redirect
        end

        test 'updates the label price' do
          put(backoffice_label_price_url(id: label_price.id, format: :turbo_stream), params: valid_params)

          label_price.reload
          assert_equal 'Book', label_price.product_type
          assert_equal 1, label_price.range_start
          assert_equal 10, label_price.range_end
          assert_equal 100.0, label_price.price_mxn
          assert_equal 7.0, label_price.price_usd
          assert_equal 'kg', label_price.unit
        end
      end

      describe 'with invalid params' do
        test 'appends flash message' do
          put(backoffice_label_price_url(id: label_price.id, format: :turbo_stream), params: invalid_params)

          assert_turbo_stream action: :append, target: 'flash'
        end

        test 'does not update the label price' do
          original_range_start = label_price.range_start
          original_range_end = label_price.range_end

          put(backoffice_label_price_url(id: label_price.id, format: :turbo_stream), params: invalid_params)

          label_price.reload
          assert_equal original_range_start, label_price.range_start
          assert_equal original_range_end, label_price.range_end
        end
      end
    end
  end
end
