# frozen_string_literal: true

class AccountMailerJob < ApplicationJob
  queue_as :default

  def perform(user_id, method_name)
    EmailService.public_send(method_name, user: User.find(user_id))
  end
end
