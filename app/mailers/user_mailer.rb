# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def send_email_verification
    @user = params[:user]
    mail subject: t('.subject'), to: @user.email
  end
end
