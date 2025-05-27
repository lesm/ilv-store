# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    mail subject: 'Reset your password', to: @user.email
  end
end
