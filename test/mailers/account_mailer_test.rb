# frozen_string_literal: true

require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase
  let(:user) { create(:user, email: 'test@mail.com') }

  test '.reset_password' do
    email = AccountMailer.with(user:).reset_password

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal 'Restablecer contraseña', email.subject
    assert_match(/Puede restablecer su contraseña/, email.body.to_s)
  end

  test '.verify_email' do
    email = AccountMailer.with(user:).verify_email

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal 'Verifica tu cuenta', email.subject
    assert_match(/Puede verificar el correo electrónico de su cuenta/, email.body.to_s)
  end
end
