# frozen_string_literal: true

class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]

  layout 'session'

  def new; end

  def edit; end

  def create
    if (user = User.find_by(email: params[:email]))
      AccountMailerJob.perform_later(user.id, :send_reset_password)
    end

    redirect_to new_session_path, notice: t('.success')
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: t('.success')
    else
      redirect_to edit_password_path(params[:token]), alert: t('.error')
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: t('.invalid_token')
  end
end
