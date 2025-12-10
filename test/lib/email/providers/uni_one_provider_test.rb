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

            assert_raises(RuntimeError, /Failed to send email/) do
              provider.send_email(message_delivery:)
            end
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
        end
      end
    end
  end
end
