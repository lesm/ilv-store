# frozen_string_literal: true

module Email
  module Providers
    class UniOneProvider < BaseProvider
      def send_email(message_delivery:)
        return message_delivery.deliver_later if Rails.env.development?

        response = post_send_email(message_delivery)

        return true if response.success?

        raise "Failed to send email: #{response.status} - #{response.body}"
      end

      private

      def post_send_email(message_delivery)
        connection.post(
          '/en/transactional/api/v1/email/send.json',
          body(message_delivery).to_json
        )
      end

      def body(message_delivery) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        recipients = [{ 'email' => message_delivery.to.first }]
        headers = { 'To' => message_delivery.to.first }

        if message_delivery.cc.present?
          recipients << { 'email' => message_delivery.cc.first }
          headers['CC'] = message_delivery.cc.first
        end

        {
          'message' => {
            'recipients' => recipients,
            'headers' => headers,
            'global_language' => 'es',
            'body' => { 'html' => message_delivery.decode_body },
            'subject' => message_delivery.subject,
            'from_email' => message_delivery.from.first,
            'from_name' => 'ILV Tienda México',
            'reply_to' => message_delivery.reply_to.first,
            'reply_to_name' => 'ILV Tienda México'
          }
        }
      end

      def connection
        Faraday.new(url: 'https://us1.unione.io/') do |conn|
          conn.headers = headers
          conn.adapter Faraday.default_adapter
        end
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'X-API-KEY' => ENV.fetch('UNI_ONE_API_KEY', 'UNI_ONE_API_KEY')
        }
      end
    end
  end
end
