# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = find_cart
    @address = find_address
  end

  def show
    request.variant = :drawer
    @order = current_user.orders
                         .includes(items: [product: [:translations, { cover_attachment: :blob }]])
                         .find(params[:id])
  end

  def create # rubocop:disable Metrics/AbcSize, Metric/MethodLength
    @order = build_order

    if @order.save
      current_cart.clear
      OrderMailerJob.perform_later(@order.id, :send_order_created)
      redirect_to orders_path, notice: t('.success')
    else
      flash.now[:alert] = @order.errors.full_messages.to_sentence
      @cart = find_cart
      @address = find_address
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_cart
    Cart
      .includes(items: [product: [:translations, { cover_attachment: :blob }]])
      .find_by(user: current_user)
  end

  def find_address
    current_user.default_address || current_user.addresses.first
  end

  def build_order
    Order.new(
      subtotal: current_cart.total_price,
      total: current_cart.total_price,
      address_attributes: address_attributes,
      items_attributes: items_attributes,
      user: current_user
    )
  end

  def address_attributes
    address = Address.find_by(id: order_params[:address_id])
    return {} unless address

    address.dup.attributes.except('id', 'created_at', 'updated_at').tap do |hash|
      hash['default'] = false
    end
  end

  def items_attributes
    current_cart.items.map do |item|
      {
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.price
      }
    end
  end

  def order_params
    params.expect(
      order: [:address_id]
    )
  end
end
