# frozen_string_literal: true

module Backoffice
  class BaseController < ActionController::Base
    include Authentication

    before_action :authorize_admin!

    layout -> { turbo_frame_request? ? 'turbo_rails/frame' : 'backoffice' }

    private

    def authorize_admin!
      return if current_user.admin?

      redirect_to root_path, alert: t('backoffice.base.unauthorized', email: current_user.email)
    end

    # Overrides the redirect_to_new_session method from Authentication module
    # Backoffice cobntrollers are not under locale scope
    def redirect_to_new_session(locale)
      flash[:alert] = t('authentication.required', locale:)

      redirect_to new_session_path
    end
  end
end
