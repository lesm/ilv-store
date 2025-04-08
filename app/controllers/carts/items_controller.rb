# frozen_string_literal: true

module Carts
  class ItemsController < ApplicationController
    def create
      cart = current_cart
      product = Product.find(params[:product_id])

      @item = cart.items.find_by(product:) || cart.items.new(product:)
      @item.increment(:quantity) if @item.persisted?
      @item.save

      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Item added to cart' }
        format.turbo_stream
      end
    end

    def destroy
      cart = current_cart
      @item = cart.items.find(params[:id])
      @item.destroy

      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Item removed from cart' }
        format.turbo_stream
      end
    end

    private

    def current_cart
      Cart.find_or_create_by(user: current_user)
    end
  end
end
