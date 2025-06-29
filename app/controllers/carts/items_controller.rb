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
      @item = current_cart.items.find(params[:id])
      @item.update(quantity: quantity_param)

      respond_to do |format|
        format.turbo_stream
      end
    end

    def destroy
      @item = current_cart.items.find(params[:id])
      @item.destroy

      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Item removed from cart' }
        format.turbo_stream
      end
    end

    private

    def broadcast_animate_cart
      Turbo::StreamsChannel.broadcast_append_to(
        current_cart,
        target: "number_of_items_cart_#{current_cart.id}",
        partial: 'carts/ping_effect_stream', locals: { cart: current_cart }
      )
    end

    def find_or_initialize_cart_item
      item = current_cart.items.find_by(product_id: product.id)
      item ||= current_cart.items.new(cart_item_params.merge(price: product.price))
      item.tap { it.increment(:quantity, quantity_param) if it.persisted? }
    end

    def product
      @product ||= Product.find(cart_item_params[:product_id])
    end

    def cart_item_params
      params.expect(cart_item: %i[product_id quantity])
    end

    def quantity_param
      params.dig(:cart_item, :quantity).to_i.abs
    end
  end
end
