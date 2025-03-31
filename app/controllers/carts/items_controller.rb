# frozen_string_literal: true

module Carts
  class ItemsController < ApplicationController
    def create
      cart = current_cart
      product = Product.find(params[:product_id])

      cart.items.create(product: product, quantity: 1)
    end

    def destroy
      cart = current_cart
      item = cart.items.find(params[:id])
      item.destroy
    end

    private

    def current_cart
      Cart.find_or_create_by(user: current_user)
    end
  end
end
