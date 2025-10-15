# frozen_string_literal: true

# Background job to release expired stock reservations
# Should be scheduled to run every 10 minutes
#
# Schedule in config/recurring.yml (for solid_queue):
# production:
#   release_expired_reservations:
#     class: ReleaseExpiredStockReservationsJob
#     schedule: every 10 minutes
#
class ReleaseExpiredStockReservationsJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = StockReservation.expired_pending.count
    StockReservation.release_expired
    released_count = expired_count - StockReservation.expired_pending.count

    Rails.logger.info "Released #{released_count} expired stock reservations"
    released_count
  end
end
