# frozen_string_literal: true

class EmailService
  class << self
    def send_verify_email(user:)
      provider.send_email(message_delivery: AccountMailer.with(user:).verify_email)
    end

    def send_reset_password(user:)
      provider.send_email(message_delivery: AccountMailer.with(user:).reset_password)
    end

    def send_order_created(order:)
      provider.send_email(message_delivery: OrderMailer.with(order:).created)
    end

    def provider
      Email::Providers::UniOneProvider.new
    end
  end
end
