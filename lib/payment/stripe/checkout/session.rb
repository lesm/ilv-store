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
              mode: 'payment',
              success_url:,
              cancel_url:
            )
          end

          private

          def line_items(order) # rubocop:disable Metrics/MethodLength
            order.items.map do |item|
              {
                price_data: {
                  currency: 'mxn',
                  product_data: {
                    name: item.product.title,
                    description: item.product.subtitle
                  },
                  unit_amount: (item.price * 100).to_i
                },
                quantity: item.quantity
              }
            end
          end
        end
      end
    end
  end
end
