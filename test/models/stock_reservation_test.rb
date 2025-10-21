# frozen_string_literal: true

require 'test_helper'

class StockReservationTest < ActiveSupport::TestCase
  let(:product) { create(:product, stock: 10, reserved_stock: 0) }
  let(:order) { create(:order) }
  let(:build_reservation) { build(:stock_reservation, product:, order:) }

  describe 'validations' do
    test 'validates quantity is greater than 0' do
      build_reservation.quantity = 0
      assert_not build_reservation.valid?
      assert build_reservation.errors[:quantity].present?
    end

    test 'validates presence of reserved_until' do
      build_reservation.reserved_until = nil
      assert_not build_reservation.valid?
      assert build_reservation.errors[:reserved_until].present?
    end

    test 'validates stock availability for active reservations' do
      # Should be valid when stock is available
      reservation = build(:stock_reservation, product:, quantity: 5, order:, status: 'active')
      assert reservation.valid?

      # Should be invalid when stock is not available
      reservation = build(:stock_reservation, product:, quantity: 15, order:, status: 'active')
      assert_not reservation.valid?
      assert_includes reservation.errors[:base], 'Not enough stock available'
    end

    test 'does not validate stock availability for non-active reservations' do
      # Committed reservations don't check stock
      reservation = build(:stock_reservation, product:, quantity: 15, order:, status: 'committed')
      assert reservation.valid?

      # Expired reservations don't check stock
      reservation = build(:stock_reservation, product:, quantity: 15, order:, status: 'expired')
      assert reservation.valid?
    end
  end

  describe 'scopes' do
    test 'active scope returns only active and not expired reservations' do
      active_future = create(:stock_reservation, :active)
      create(:stock_reservation, :expired_time)
      create(:stock_reservation, :committed)

      assert_equal [active_future], StockReservation.active.to_a
    end

    test 'expired_pending scope returns active reservations past their expiry time' do
      create(:stock_reservation, :active)
      expired = create(:stock_reservation, :expired_time)
      create(:stock_reservation, :expired)

      assert_equal [expired], StockReservation.expired_pending.to_a
    end
  end

  describe '.reserve_for_order' do
    test 'creates reservations for all order items' do
      product1 = create(:product, stock: 10, reserved_stock: 0)
      product2 = create(:product, stock: 20, reserved_stock: 0)

      order = create(:order, workflow_status: 'draft')
      order.items.destroy_all # Clear default items
      order.items.create!(product: product1, quantity: 2, price_mxn: 10, price_usd: 0.50)
      order.items.create!(product: product2, quantity: 3, price_mxn: 15, price_usd: 0.75)

      assert_difference 'StockReservation.count', 2 do
        StockReservation.reserve_for_order(order)
      end

      product1.reload
      product2.reload

      assert_equal 2, product1.reserved_stock
      assert_equal 3, product2.reserved_stock
    end

    test 'sets correct reservation attributes' do
      order.update!(workflow_status: 'draft')
      order.items.destroy_all
      order.items.create!(product:, quantity: 2, price_mxn: 10, price_usd: 0.50)

      reservations = StockReservation.reserve_for_order(order)
      reservation = reservations.first

      assert_equal order, reservation.order
      assert_equal product, reservation.product
      assert_equal 2, reservation.quantity
      assert_equal 'active', reservation.status
      assert reservation.reserved_until > Time.current
      assert reservation.reserved_until <= 30.minutes.from_now
    end

    test 'rolls back all reservations if one fails due to insufficient stock' do
      product2 = create(:product, stock: 5, reserved_stock: 0)

      order = create(:order, workflow_status: 'draft')
      order.items.destroy_all
      order.items.create!(product:, quantity: 2, price_mxn: 10, price_usd: 0.50)
      order.items.create!(product: product2, quantity: 10, price_mxn: 15, price_usd: 0.75) # Not enough stock

      assert_no_difference 'StockReservation.count' do
        assert_raises(ActiveRecord::RecordInvalid) do
          StockReservation.reserve_for_order(order)
        end
      end

      product.reload
      product2.reload

      # Neither product should have reserved stock
      assert_equal 0, product.reserved_stock
      assert_equal 0, product2.reserved_stock
    end
  end

  describe '.release_expired' do
    test 'expires all pending expired reservations' do
      product.update!(reserved_stock: 6)
      expired1 = create(:stock_reservation, :expired_time, product: product, quantity: 2, status: 'active')
      expired2 = create(:stock_reservation, :expired_time, product: product, quantity: 4, status: 'active')

      # Create an active non-expired reservation
      active = create(:stock_reservation, :active, product:, quantity: 1)

      StockReservation.release_expired

      assert_equal 'expired', expired1.reload.status
      assert_equal 'expired', expired2.reload.status
      assert_equal 'active', active.reload.status # Should not be expired

      product.reload
      assert_equal 0, product.reserved_stock # Both expired released (6 - 2 - 4 = 0)
    end
  end

  describe '#commit!' do
    test 'marks reservation as committed and reduces stock' do
      product.update!(reserved_stock: 5)
      reservation = create(:stock_reservation, product:, quantity: 2, status: 'active')

      reservation.commit!

      assert_equal 'committed', reservation.status

      product.reload
      assert_equal 8, product.stock # Reduced by 2
      assert_equal 3, product.reserved_stock # Reduced by 2
    end

    test 'should be called within transaction' do
      product.update!(reserved_stock: 2)
      reservation = create(:stock_reservation, product:, quantity: 2, status: 'active')

      # Simulate transaction
      ActiveRecord::Base.transaction do
        reservation.commit!
        # If an error occurs here, everything should roll back
      end

      product.reload
      assert_equal 8, product.stock
      assert_equal 0, product.reserved_stock
    end
  end

  describe '#cancel!' do
    test 'marks reservation as cancelled and releases reserved stock' do
      product.update!(reserved_stock: 5)
      reservation = create(:stock_reservation, product:, quantity: 2, status: 'active')
      reservation.cancel!

      assert_equal 'cancelled', reservation.status

      product.reload
      assert_equal 10, product.stock # Stock unchanged
      assert_equal 3, product.reserved_stock # Reduced by 2
    end

    test 'does not cancel already committed reservations' do
      reservation = create(:stock_reservation, :committed, product: product, quantity: 2)
      reservation.cancel!

      assert_equal 'committed', reservation.status # Still committed
    end

    test 'does not cancel already expired reservations' do
      reservation = create(:stock_reservation, :expired, product:, quantity: 2)
      reservation.cancel!

      assert_equal 'expired', reservation.status # Still expired
    end
  end

  describe '#expire!' do
    test 'marks active reservation as expired and releases reserved stock' do
      reservation = create(:stock_reservation, :expired_time, product:, quantity: 2)
      product.update!(reserved_stock: 5)
      reservation.expire!

      assert_equal 'expired', reservation.status

      product.reload
      assert_equal 10, product.stock # Stock unchanged
      assert_equal 3, product.reserved_stock # Reduced by 2
    end

    test 'does not expire non-active reservations' do
      reservation = create(:stock_reservation, :committed, product:, quantity: 2)
      reservation.expire!

      assert_equal 'committed', reservation.status # Still committed
    end

    test 'runs in its own transaction' do
      product.update!(reserved_stock: 2)
      reservation = create(:stock_reservation, :expired_time, product:, quantity: 2)
      reservation.expire!

      product.reload
      assert_equal 0, product.reserved_stock
    end
  end

  describe 'integration: complete order flow' do
    test 'full reservation lifecycle: create, commit on payment' do
      order.update!(workflow_status: 'draft')
      order.items.destroy_all
      order.items.create!(product:, quantity: 3, price_mxn: 10, price_usd: 0.50)

      # Create reservation
      reservations = StockReservation.reserve_for_order(order)
      reservation = reservations.first

      product.reload
      assert_equal 10, product.stock
      assert_equal 3, product.reserved_stock
      assert_equal 7, product.available_stock

      # Commit on payment
      reservation.commit!

      product.reload
      assert_equal 7, product.stock
      assert_equal 0, product.reserved_stock
      assert_equal 7, product.available_stock
    end

    test 'full reservation lifecycle: create, cancel on payment failure' do
      order.update!(workflow_status: 'draft')
      order.items.destroy_all
      order.items.create!(product: product, quantity: 3, price_mxn: 10, price_usd: 0.50)

      # Create reservation
      reservations = StockReservation.reserve_for_order(order)
      reservation = reservations.first

      product.reload
      assert_equal 3, product.reserved_stock

      # Cancel on payment failure
      reservation.cancel!

      product.reload
      assert_equal 10, product.stock
      assert_equal 0, product.reserved_stock
      assert_equal 10, product.available_stock
    end

    test 'full reservation lifecycle: create, expire on timeout' do
      order.update!(workflow_status: 'draft')
      order.items.destroy_all
      order.items.create!(product: product, quantity: 3, price_mxn: 10, price_usd: 0.50)

      # Create reservation
      reservations = StockReservation.reserve_for_order(order)
      reservation = reservations.first

      product.reload
      assert_equal 3, product.reserved_stock

      # Simulate time passing
      reservation.update_column(:reserved_until, 1.hour.ago) # rubocop:disable Rails/SkipsModelValidations

      # Background job expires it
      reservation.expire!

      product.reload
      assert_equal 10, product.stock
      assert_equal 0, product.reserved_stock
      assert_equal 10, product.available_stock
    end
  end
end
