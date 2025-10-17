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

    describe 'when redirected from Stripe cancel' do
      test 'cancels stock reservations for draft order' do
        order = create(:order, :order_draft, user:)
        token = Rails.application.message_verifier(:from_stripe).generate({ order_id: order.id, user_id: user.id })
        # Simulate cancel redirect from Stripe
        get(new_order_url(address_id: order.address.id, token:))

        # Should cancel stock reservations
        assert_equal 2, order.stock_reservations.count
        assert_equal 'cancelled', order.stock_reservations.first.reload.status
      end

      test 'redirects to new order page with address_id' do
        order = create(:order, :order_draft, user:)
        token = Rails.application.message_verifier(:from_stripe).generate({ order_id: order.id, user_id: user.id })
        get(new_order_url(address_id: order.address.id, token:))

        assert_redirected_to new_order_path(address_id: order.address.id)
      end

      test 'handles order not found gracefully' do
        # Generate token with non-existent order_id
        token = Rails.application.message_verifier(:from_stripe).generate({ order_id: 'non-existent-id',
                                                                            user_id: user.id })

        get new_order_url(token:)

        # renders the new page without errors
        assert_response :success
      end

      test 'handles invalid token gracefully' do
        # Invalid token
        get new_order_url(token: 'invalid-token')

        # rescues InvalidSignature and render page normally
        assert_response :success
      end
    end
  end

  describe '#GET show' do
    test 'returns 200 status code' do
      get order_url(id: create(:order, :order_created, user:).id)
      assert_response :success
    end

    test 'clears cart items when request can from stripe' do
      order = create(:order, :order_draft, user:)
      token = Rails.application.message_verifier(:from_stripe).generate({ order_id: order.id, user_id: user.id })

      assert_difference 'user.cart.items.count', -user.cart.items.count do
        get order_url(id: order.id, token:)
      end
    end
  end

  describe 'POST #create' do
    describe 'with valid params' do
      before do
        Stripe::Checkout::Session.stubs(:create).returns(
          Data.define(:id, :object, :url).new(
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
