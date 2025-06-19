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
  end
end
