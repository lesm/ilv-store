# frozen_string_literal: true

require 'test_helper'

class EmailServiceTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:provider) { Email::Providers::UniOneProvider.new }
  let(:order) { create(:order, :created, user:) }

  describe '.provider' do
    test 'returns the UniOne provider' do
      assert_instance_of Email::Providers::UniOneProvider, EmailService.provider
    end
  end

  describe 'mailers' do
    before do
      EmailService.stubs(:provider).returns(provider)
    end

    def assert_email_sent(&)
      provider
        .expects(:send_email)
        .with(message_delivery: instance_of(ActionMailer::Parameterized::MessageDelivery))

      yield
    end

    test 'sends the verify email' do
      assert_email_sent { EmailService.send_verify_email(user:) }
    end

    test 'sends the reset password email' do
      assert_email_sent { EmailService.send_reset_password(user:) }
    end

    test 'sends an email for a created order' do
      assert_email_sent { EmailService.send_order_created(order:) }
    end
  end
end
