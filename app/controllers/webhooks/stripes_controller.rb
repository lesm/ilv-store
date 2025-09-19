# frozen_string_literal: true

module Webhooks
  class StripesController < ActionController::API
    def create
      event = begin
        construct_event
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        return render json: { error: 'Invalid request' }, status: :bad_request
      end

      process_event(event)

      render json: { received: true }
    end

    private

    def construct_event
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
      Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    end

    def process_event(event)
      case event['type']
      when 'checkout.session.completed'
        handle_successful_payment(event['data']['object'])
      when 'payment_intent.payment_failed'
        handle_failed_payment(event['data']['object'])
      end
    end

    def handle_successful_payment(session)
      order = Order.find_by(stripe_session_id: session['id'])
      return unless order

      return if order.payment_status_paid?

      order.update!(
        payment_status: :paid,
        workflow_status: :created,
        stripe_payment_intent_id: session['payment_intent']
      )

      OrderMailerJob.perform_later(order.id, :send_order_created)
    end

    def handle_failed_payment(session)
      order = Order.find_by(stripe_session_id: session['id'])
      return unless order

      order.update!(
        payment_status: :failed,
        stripe_payment_intent_id: session['payment_intent']
      )
    end
  end
end
