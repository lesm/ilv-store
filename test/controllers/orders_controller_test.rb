# frozen_string_literal: true

require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user, :with_cart) }
  let(:params) do
    {
      order: {
        address_id: create(:address, :oxxo_bustamante, addressable: user).id
      }
    }
  end

  before do
    authenticate_as(user)
  end

  describe 'GET #index' do
    test 'returns a 200 response' do
      get orders_url
      assert_response :success
    end
  end

  describe '#GET new' do
    test 'returns 200 status code' do
      get new_order_url
      assert_response :success
    end
  end

  describe '#GET show' do
    test 'returns 200 status code' do
      get order_url(id: create(:order, user:).id, turbo_frame: 'drawer')
      assert_response :success
    end
  end

  describe 'POST #create' do
    describe 'with valid params' do
      test 'redirects to the orders page' do
        post(orders_url(format: :turbo_stream), params:)

        assert_redirected_to orders_url
      end
    end

    describe 'with invalid params' do
      test 'returns unprocessable_entity response' do
        params[:order][:address_id] = nil
        post(orders_url(format: :html), params:)

        assert_response :unprocessable_entity
      end
    end
  end
end
