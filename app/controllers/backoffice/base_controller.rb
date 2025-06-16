# frozen_string_literal: true

module Backoffice
  class BaseController < ActionController::Base
    include Authentication

    before_action :authorize_admin!

    private

    def authorize_admin!
      redirect_to root_path, alert: 'unauthorized' unless current_user.admin?
    end
  end
end
