# frozen_string_literal: true

require 'test_helper'

module Email
  module Providers
    class UniOneProviderTest < ActiveSupport::TestCase
      let(:provider) { Email::Providers::UniOneProvider.new }
      let(:user) { create(:user) }

      describe '#send_email' do
        let(:message_delivery) { AccountMailer.with(user:).verify_email }

        test 'sends email successfully' do
          stub_request(:post, 'https://us1.unione.io/en/transactional/api/v1/email/send.json')
            .to_return(status: 200, body: '', headers: {})

          assert provider.send_email(message_delivery:)
        end

        test 'raises an error when the response is not successful' do
          stub_request(:post, 'https://us1.unione.io/en/transactional/api/v1/email/send.json')
            .to_return(status: 500, body: 'Internal Server Error', headers: {})

          assert_raises(RuntimeError, /Failed to send email/) do
            provider.send_email(message_delivery:)
          end
        end
      end
    end
  end
end
