# frozen_string_literal: true

require 'test_helper'

module Webwooks
  class StripesControllerTest < ActionDispatch::IntegrationTest
    let(:order) do
      create(:order, :order_created,
             stripe_session_id: 'cs_test_b1Or7oDLkW1XF31oA12Xv4AfW47n6fp6ZatIKsS9PBupMp02QAMAnnnao7')
    end

    let(:headers) do
      {
        'Content-Type': 'application/json',
        HTTP_STRIPE_SIGNATURE: 't=1757649011,v1=d67ccc5ac7a1525c1d298295bdb53e4ce26b773c2aeba7aec21ddb3b105eccad,v0=84ee30fd13455ccca4037ca2e4fe2b75c4db9ad1e3407c471d34161e50a0ad1e' # rubocop:disable Layout/LineLength
      }
    end

    describe 'POST #create' do
      test 'process a checkout.session.completed event webhook' do
        order
        Stripe::Webhook::Signature.stubs(:verify_header).returns(true)

        post(webhooks_stripe_path, params: event_type('checkout.session.completed'), headers:)

        assert_response :success
      end

      test 'process a payment_intent.payment_falied event webhook' do
        order
        Stripe::Webhook::Signature.stubs(:verify_header).returns(true)

        post(webhooks_stripe_path, params: event_type('payment_intent.payment_failed'), headers:)

        assert_response :success
      end

      test 'process an invalid webhook' do
        Stripe::Webhook
          .stubs(:construct_event)
          .raises(Stripe::SignatureVerificationError.new('Invalid signature', 'sig_header'))

        post(webhooks_stripe_path, params: body, headers:)

        assert_response :bad_request
      end
    end

    def event_type(type)
      Rails.root.join("test/fixtures/webwooks/stripe/event-#{type}.json").read
    end
  end
end
