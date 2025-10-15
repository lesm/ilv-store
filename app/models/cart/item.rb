# frozen_string_literal: true

class Cart
  class Item < ApplicationRecord
    belongs_to :product
    belongs_to :cart, touch: true

    normalizes :quantity, with: ->(q) { q.to_i.abs }

    validates :quantity, numericality: { greater_than: 0 }
    validate :stock_availability

    delegate :title, :subtitle, :cover, to: :product

    after_destroy :update_cart_label_price
    after_save :update_cart_label_price

    private

    def stock_availability
      return if product.available_stock >= quantity

      errors.add(:quantity, :not_enough_stock, count: product.available_stock)
    end

    def update_cart_label_price
      cart.update_label_price
    end
  end
end
