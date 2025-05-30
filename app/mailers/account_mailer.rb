# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def reset_password
    @user = params[:user]
    mail subject: t('.subject'), to: email_address_with_name(@user.email, @user.name)
  end

  def verify_email
    @user = params[:user]
    mail subject: t('.subject'), to: email_address_with_name(@user.email, @user.name)
  end
end
