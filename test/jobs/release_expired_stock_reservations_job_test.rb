# frozen_string_literal: true

require 'test_helper'

class ReleaseExpiredStockReservationsJobTest < ActiveJob::TestCase
  let(:product) { create(:product, stock: 10, reserved_stock: 5) }
  let(:product2) { create(:product, stock: 20, reserved_stock: 3) }

  test 'releases all expired reservations' do
    expired1 = create(:stock_reservation, :expired_time, product: product, quantity: 2, status: 'active')
    expired2 = create(:stock_reservation, :expired_time, product: product2, quantity: 3, status: 'active')

    active = create(:stock_reservation, :active, product:)

    ReleaseExpiredStockReservationsJob.perform_now

    # Expired reservations should be marked as expired
    assert_equal 'expired', expired1.reload.status
    assert_equal 'expired', expired2.reload.status

    # Active reservation should remain active
    assert_equal 'active', active.reload.status

    # Reserved stock should be released for expired reservations
    product.reload
    product2.reload
    assert_equal 3, product.reserved_stock # 5 - 2 = 3
    assert_equal 0, product2.reserved_stock # 3 - 3 = 0
  end

  test 'returns count of released reservations' do
    create(:stock_reservation, :active, product:, quantity: 2)
    create_list(:stock_reservation, 3, :expired_time, product:, quantity: 2, status: 'active')

    count = ReleaseExpiredStockReservationsJob.perform_now

    assert_equal 3, count
  end

  test 'logs released count' do
    create_list(:stock_reservation, 2, :expired_time, product:, quantity: 2, status: 'active')

    # Verify logging happens (checking the logger receives info call)
    Rails.logger.expects(:info).with { |msg| msg.include?('Released') && msg.include?('2') }

    ReleaseExpiredStockReservationsJob.perform_now
  end

  test 'does nothing when no expired reservations exist' do
    create_list(:stock_reservation, 3, :active)

    count = ReleaseExpiredStockReservationsJob.perform_now

    assert_equal 0, count
  end

  test 'does not process already expired status reservations' do
    # Create reservation with expired status (not active)
    already_expired = create(:stock_reservation, :expired, product: product, quantity: 2)

    count = ReleaseExpiredStockReservationsJob.perform_now

    # Should not process it again
    assert_equal 0, count
    assert_equal 'expired', already_expired.reload.status
  end

  test 'does not process committed reservations' do
    # Create committed reservation (should never be processed)
    committed = create(:stock_reservation, :committed, product: product, quantity: 2)

    count = ReleaseExpiredStockReservationsJob.perform_now

    assert_equal 0, count
    assert_equal 'committed', committed.reload.status
  end

  test 'does not process cancelled reservations' do
    # Create cancelled reservation
    cancelled = create(:stock_reservation, :cancelled, product: product, quantity: 2)

    count = ReleaseExpiredStockReservationsJob.perform_now

    assert_equal 0, count
    assert_equal 'cancelled', cancelled.reload.status
  end

  test 'can be enqueued as background job' do
    assert_enqueued_with(job: ReleaseExpiredStockReservationsJob) do
      ReleaseExpiredStockReservationsJob.perform_later
    end
  end

  test 'uses default queue' do
    job = ReleaseExpiredStockReservationsJob.new
    assert_equal 'default', job.queue_name
  end
end
