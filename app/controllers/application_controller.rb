# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def current_cart
    @current_cart ||= Cart.find_or_create_by(user: current_user)
  end
end
