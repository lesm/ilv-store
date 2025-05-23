# frozen_string_literal: true

module Users
  class EmailVerificationsController < ApplicationController
    allow_unauthenticated_access only: %i[show]
    before_action :set_user_by_token, only: %i[show]

    def show
      @user.update(verified: true)

      start_new_session_for @user
      redirect_to after_authentication_url, notice: t('.success')
    end

    def set_user_by_token
      @user = User.find_by_email_verification_token!(params[:token]) # rubocop:disable Rails/DynamicFindBy
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to root_path, alert: t('.invalid_token')
    end
  end
end
