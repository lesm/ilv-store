# frozen_string_literal: true

class Cart
  class Item < ApplicationRecord
    belongs_to :product
    belongs_to :cart, touch: true

    normalizes :quantity, with: ->(q) { q.to_i.abs }

    validates :quantity, numericality: { greater_than: 0 }
    validate :stock_availability

    delegate :title, :subtitle, :cover, to: :product

    private

    def stock_availability
      return if product.stock >= quantity

      errors.add(:quantity, :not_enough_stock, count: product.stock)
    end
  end
end
