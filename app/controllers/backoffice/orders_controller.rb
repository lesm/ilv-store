# frozen_string_literal: true

module Backoffice
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user).all
    end
  end
end
