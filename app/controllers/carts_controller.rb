# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = current_cart
  end

  private

  def current_cart
    Cart.find_or_create_by(user: current_user)
  end
end
