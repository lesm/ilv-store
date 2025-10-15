# frozen_string_literal: true

class StockReservation < ApplicationRecord
  enum :status, {
    active: 'active',
    committed: 'committed',
    expired: 'expired',
    cancelled: 'cancelled'
  }, prefix: true

  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :reserved_until, presence: true
  validate :stock_must_be_available, if: :status_active?

  # Reserve stock for 30 minutes
  RESERVATION_DURATION = 30.minutes

  scope :active, -> { where(status: 'active').where('reserved_until > ?', Time.current) }
  scope :expired_pending, -> { where(status: 'active').where(reserved_until: ..Time.current) }

  class << self
    def reserve_for_order(order) # rubocop:disable Metrics/MethodLength
      transaction do
        order.items.map do |item|
          reservation = create!(
            order: order,
            product: item.product,
            quantity: item.quantity,
            reserved_until: RESERVATION_DURATION.from_now,
            status: 'active'
          )
          # Increment reserved_stock after successful creation
          item.product.reserve_stock!(reservation.quantity)
          reservation
        end
      end
    end

    def release_expired
      expired_pending.find_each(&:expire!)
    end
  end

  # NOTE: Called within transaction from Order#commit_stock_reservations!
  def commit!
    update!(status: 'committed')
    product.decrement!(:stock, quantity) # rubocop:disable Rails/SkipsModelValidations
    product.decrement!(:reserved_stock, quantity) # rubocop:disable Rails/SkipsModelValidations
  end

  # NOTE: Called within transaction from Order#cancel_stock_reservations!
  def cancel!
    return if status_committed? || status_expired?

    update!(status: 'cancelled')
    product.decrement!(:reserved_stock, quantity) # rubocop:disable Rails/SkipsModelValidations
  end

  # Mark as expired and release stock
  def expire!
    transaction do
      return unless status_active?

      update!(status: 'expired')
      product.decrement!(:reserved_stock, quantity) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def stock_must_be_available
    return unless product
    return if product.can_reserve?(quantity)

    errors.add(:base, 'Not enough stock available')
  end
end
