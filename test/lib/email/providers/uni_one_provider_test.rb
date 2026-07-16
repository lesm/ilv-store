# frozen_string_literal: true

require 'test_helper'

module Email
  module Providers
    class UniOneProviderTest < ActiveSupport::TestCase
      let(:provider) { Email::Providers::UniOneProvider.new }
      let(:user) { create(:user) }

      module EmailSendingBehavior
        extend ActiveSupport::Concern

        included do
          test 'sends email successfully' do
            stub_request(:post, 'https://us1.unione.io/en/transactional/api/v1/email/send.json')
              .to_return(status: 200, body: '', headers: {})

            assert provider.send_email(message_delivery:)
          end

          test 'raises an error when the response is not successful' do
            stub_request(:post, 'https://us1.unione.io/en/transactional/api/v1/email/send.json')
              .to_return(status: 500, body: 'Internal Server Error', headers: {})

            error = assert_raises(RuntimeError) do
              provider.send_email(message_delivery:)
            end

            assert_match(/Failed to send email/, error.message)
          end
        end
      end

      describe '#send_email' do
        describe 'without CC' do
          let(:message_delivery) { AccountMailer.with(user:).verify_email }

          include EmailSendingBehavior
        end

        describe 'with CC' do
          let(:order) { create(:order, user:) }
          let(:message_delivery) { OrderMailer.with(order:).created }

          include EmailSendingBehavior

          test 'sends every cc recipient from a comma-separated address list' do
            previous_sales_email = ENV.fetch('SALES_EMAIL_ADDRESS', nil)
            ENV['SALES_EMAIL_ADDRESS'] = 'ventas@ilvmx.org,admin_web@ilvmx.org'

            captured_request = nil
            request_stub = stub_request(:post, 'https://us1.unione.io/en/transactional/api/v1/email/send.json')
                           .to_return(status: 200, body: '', headers: {})
            request_stub.with { |request| captured_request = request }

            provider.send_email(message_delivery:)

            payload = JSON.parse(captured_request.body)
            recipient_emails = payload['message']['recipients'].pluck('email')

            assert_includes recipient_emails, 'ventas@ilvmx.org'
            assert_includes recipient_emails, 'admin_web@ilvmx.org'
            assert_equal 'ventas@ilvmx.org, admin_web@ilvmx.org', payload['message']['headers']['CC']
          ensure
            ENV['SALES_EMAIL_ADDRESS'] = previous_sales_email
          end
        end
      end
    end
  end
end
