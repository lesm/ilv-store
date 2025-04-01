# frozen_string_literal: true

module ApplicationHelper
  def current_cart
    Cart.find_or_create_by(user: current_user)
  end
end
