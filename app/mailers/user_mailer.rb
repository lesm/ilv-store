# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def send_email_verification(user)
    @user = user
    mail subject: 'Verify your email address', to: user.email
  end
end
