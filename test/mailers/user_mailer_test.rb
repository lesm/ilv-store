# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  describe '#send_email_verification' do
    let(:user) { create(:user, email: 'test@mail.com') }
    let(:email) { UserMailer.with(user:).send_email_verification }

    test 'delivers an email' do
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ['mail@mail.com'], email.from
      assert_equal ['test@mail.com'], email.to
      assert_equal 'Verifica tu cuenta', email.subject
      assert_match(/Puede confirmar el correo electrónico de su cuenta/, email.body.to_s)
    end
  end
end
