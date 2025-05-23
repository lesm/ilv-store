# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  describe '#send_email_verification' do
    let(:user) { create(:user, email: 'test@mail.com') }
    let(:email) { UserMailer.send_email_verification(user) }

    test 'delivers an email' do
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ['mail@mail.com'], email.from
      assert_equal ['test@mail.com'], email.to
      assert_equal 'Verify your email address', email.subject
      assert_match(/Please verify your email by clicking the link below/, email.body.to_s)
    end
  end
end
