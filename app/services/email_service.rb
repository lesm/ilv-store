# frozen_string_literal: true

class EmailService
  class << self
    def send_verify_email(user:)
      provider.send_email(message_delivery: AccountMailer.with(user:).verify_email)
    end

    def send_reset_password(user:)
      provider.send_email(message_delivery: AccountMailer.with(user:).reset_password)
    end

    def provider
      Email::Providers::UniOneProvider.new
    end
  end
end
