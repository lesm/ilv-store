# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def reset_password
    @user = params[:user]
    mail subject: t('.subject'), to: @user.email
  end

  def verify_email
    @user = params[:user]
    mail subject: t('.subject'), to: @user.email
  end
end
