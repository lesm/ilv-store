# frozen_string_literal: true

class OrderMailerJob < ApplicationJob
  queue_as :default

  def perform(order_id, method_name)
    EmailService.public_send(method_name, order: Order.find(order_id))
  end
end
