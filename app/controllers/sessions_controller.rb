# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_session_url, alert: 'Try again later.'
  }

  layout 'session'

  def new; end

  def create
    if (user = User.authenticate_by(params.permit(:email, :password)))
      return email_verification_required unless user.verified?

      start_new_session_for user
      redirect_to after_authentication_url, notice: t('.success')
    else
      redirect_to new_session_path, alert: t('.failure')
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def email_verification_required
    flash.now[:notice] = t('.email_verification_required')
    render :new, status: :unprocessable_content
  end
end
