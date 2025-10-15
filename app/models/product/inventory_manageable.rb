# frozen_string_literal: true

class Product
  module InventoryManageable
    extend ActiveSupport::Concern

    class InsufficientStockError < StandardError; end

    included do
      has_many :stock_reservations, dependent: :destroy
      has_many :active_reservations, lambda {
        active
      }, class_name: 'StockReservation', dependent: :destroy, inverse_of: :product

      validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :reserved_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

      # Ensure reserved_stock never exceeds actual stock
      validate :reserved_stock_within_bounds
    end

    def available_stock
      stock - reserved_stock
    end

    def can_reserve?(quantity)
      available_stock >= quantity
    end

    # Reserve stock (increases reserved_stock counter)
    def reserve_stock!(quantity)
      transaction do
        lock! # Pessimistic lock to prevent race conditions
        raise InsufficientStockError, 'Not enough stock available' unless can_reserve?(quantity)

        increment!(:reserved_stock, quantity) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    private

    def reserved_stock_within_bounds
      return if reserved_stock <= stock

      errors.add(:reserved_stock, 'cannot exceed actual stock')
    end
  end
end
