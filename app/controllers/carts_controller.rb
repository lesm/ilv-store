# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    request.variant = :drawer
    @cart = current_cart
  end
end
