# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

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
      create_list(:order, 3, :order_created, user:)

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
      get order_url(id: create(:order, :order_created, user:).id, turbo_frame: 'drawer')
      assert_response :success
    end
  end

  describe 'POST #create' do
    describe 'with valid params' do
      before do
        Stripe::Checkout::Session.stubs(:create).returns(
          ::OpenStruct.new(
            id: 'cs_test_a1b2c3d4e5f6g7h8i9j0',
            object: 'checkout.session',
            url: 'https://checkout.stripe.com/pay/cs_test_a1b2c3d4e5f6g7h8i9j0'
          )
        )

        stub_request(:post, %r{/checkout/sessions}).to_return(
          status: 201,
          body: {
            id: 'cs_test_a1b2c3d4e5f6g7h8i9j0',
            object: 'checkout.session',
            url: 'https://checkout.stripe.com/pay/cs_test_a1b2c3d4e5f6g7h8i9j0'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        stub_request(:get, 'https://checkout.stripe.com/pay/cs_test_a1b2c3d4e5f6g7h8i9j0').to_return(
          status: 200,
          body: '',
          headers: { 'Content-Type' => 'text/html' }
        )
      end

      test 'redirects to the orders page' do
        post(orders_url(format: :turbo_stream), params:)

        assert_redirected_to 'https://checkout.stripe.com/pay/cs_test_a1b2c3d4e5f6g7h8i9j0'
      end
    end

    describe 'stripe raises an error' do
      before do
        Payment::Stripe::Checkout::Session.stubs(:create).raises(Stripe::StripeError.new('Stripe error'))
      end

      test 'redirects to the order page with an alert message' do
        post(orders_url(format: :html), params:)

        error_message = 'Try again, there was an error with the payment processor: Stripe error'
        assert_redirected_to order_url(Order.last)
        assert_equal error_message, flash[:alert]
      end
    end

    describe 'with invalid params' do
      test 'returns unprocessable_content response' do
        params[:order][:address_id] = nil
        post(orders_url(format: :html), params:)

        assert_response :unprocessable_content
      end
    end
  end
end
