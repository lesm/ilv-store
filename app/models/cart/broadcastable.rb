# frozen_string_literal: true

class Cart
  module Broadcastable
    extend ActiveSupport::Concern

    included do
      after_update_commit :broadcast_cart_updates
    end

    def broadcast_cart_updates
      broadcast_items_count
      broadcast_subtotal_drawer
      broadcast_subtotal_order
      broadcast_total_order
      broadcast_checkout_link if items.empty?
    end

    private

    def broadcast_items_count
      broadcast_update_to(self, target: "number_of_items_cart_#{id}", partial: 'carts/number_of_items')
    end

    def broadcast_subtotal_drawer
      broadcast_update_to(self, target: "subtotal_drawer_cart_#{id}", partial: 'carts/subtotal_drawer')
    end

    def broadcast_subtotal_order
      broadcast_update_to(self, target: "label_price_order_cart_#{id}", partial: 'orders/label_price')
      broadcast_update_to(self, target: "products_price_order_cart_#{id}", partial: 'orders/products_price')
    end

    def broadcast_total_order
      broadcast_update_to(self, target: "total_order_cart_#{id}", partial: 'orders/total')
    end

    def broadcast_checkout_link
      broadcast_update_to(self, target: "link_to_checkout_cart_#{id}", partial: 'carts/link_to_checkout')
    end
  end
end
