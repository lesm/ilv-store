# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    mail subject: t('.subject'), to: @user.email
  end
end
