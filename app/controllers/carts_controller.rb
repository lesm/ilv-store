# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    request.variant = :drawer
    @cart = current_cart
  end

  private

  def current_cart
    Cart.find_or_create_by(user: current_user)
  end
end
