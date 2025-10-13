# frozen_string_literal: true

require 'stripe'

Rails.configuration.stripe = {
  publishable_key: ENV.fetch('STRIPE_PUBLISH_KEY', nil),
  secret_key: ENV.fetch('STRIPE_SECRET_KEY', nil)
}
Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY', nil)
