# frozen_string_literal: true

require 'test_helper'

class OrderMailerJobTest < ActiveJob::TestCase
  let(:user) { create(:user) }
  let(:order) { create(:order, :created, user:) }

  test 'sends the order created email' do
    EmailService.expects(:send_order_created).with(order:)

    perform_enqueued_jobs do
      OrderMailerJob.perform_later(order.id, :send_order_created)
    end
  end
end
