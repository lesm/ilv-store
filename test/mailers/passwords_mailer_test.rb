# frozen_string_literal: true

require 'test_helper'

class PasswordsMailerTest < ActionMailer::TestCase
  let(:user) { create(:user, email_address: 'test@mail.com') }

  test '.reset' do
    email = PasswordsMailer.reset(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal 'Reset your password', email.subject
    assert_match(/You can reset your password/, email.text_part.body.to_s)
  end
end
