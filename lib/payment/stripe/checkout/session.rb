# frozen_string_literal: true

module Payment
  module Stripe
    module Checkout
      class Session
        class << self
          def create(order:, success_url:, cancel_url:)
            ::Stripe::Checkout::Session.create(
              customer_email: order.user.email,
              payment_method_types: ['card'],
              line_items: line_items(order),
              currency: order.currency,
              mode: 'payment',
              success_url:,
              cancel_url:,
              expires_at: 30.minutes.from_now.to_i
            )
          end

          private

          def line_items(order) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            items = order.items.map do |item|
              {
                price_data: {
                  currency: order.currency,
                  product_data: {
                    name: item.product.title,
                    description: item.product.subtitle
                  },
                  unit_amount: (item.price * 100).to_i
                },
                quantity: item.quantity
              }
            end

            # Add shipping label cost
            if order.label_price.positive?
              items << {
                price_data: {
                  currency: order.currency,
                  product_data: {
                    name: I18n.t('orders.payment_checkout.shipping_label'),
                    description: I18n.t('orders.payment_checkout.shipping_label_description')
                  },
                  unit_amount: (order.label_price * 100).to_i
                },
                quantity: 1
              }
            end

            items
          end
        end
      end
    end
  end
end
