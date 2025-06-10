# frozen_string_literal: true

module Email
  module Providers
    class BaseProvider
      def send_email(message_delivery:)
        raise NotImplementedError, "#{self.class.name} must implement the `send_email` method"
      end
    end
  end
end
