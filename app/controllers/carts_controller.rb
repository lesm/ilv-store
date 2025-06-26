# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    request.variant = :drawer
    @cart = Cart.includes(items: [:product]).find_by(user: current_user)
  end
end
