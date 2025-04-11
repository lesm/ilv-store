# frozen_string_literal: true

module Carts
  class ItemsController < ApplicationController
    def create
      @item = find_or_initialize_cart_item
      @item.save

      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Item added to cart' }
        format.turbo_stream do
          flash.now[:notice] = t('.item_added')
          render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
        end
      end

      broadcast_animate_cart
    end

    def update
      @item = cart.items.find(params[:id])
      @item.update(quantity: quantity_param)

      respond_to do |format|
        format.turbo_stream
      end
    end

    def destroy
      @item = cart.items.find(params[:id])
      @item.destroy

      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Item removed from cart' }
        format.turbo_stream
      end
    end

    private

    def broadcast_animate_cart
      Turbo::StreamsChannel.broadcast_append_to(
        cart,
        target: 'animate_cart_target',
        partial: 'carts/ping_effect_stream', locals: { cart: }
      )
    end

    def find_or_initialize_cart_item
      product_id = params[:product_id]

      item = cart.items.find_by(product_id:) || cart.items.new(product_id:, quantity: quantity_param)
      item.tap { it.increment(:quantity, quantity_param) if it.persisted? }
    end

    def quantity_param
      params.dig(:cart_item, :quantity).to_i.abs
    end

    def cart
      @cart ||= Cart.find_or_create_by(user: current_user)
    end
  end
end
