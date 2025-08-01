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

  def create
    @form = build_form

    if @form.save
      redirect_to orders_path, notice: t('.success')
    else
      flash.now[:alert] = @form.errors.full_messages.to_sentence
      @cart = find_cart
      @address = find_address
      render :new, status: :unprocessable_content
    end
  end

  private

  def build_form
    OrderForm.new(order_params.to_h).tap do |form|
      form.current_cart = current_cart
      form.current_user = current_user
    end
  end

  def find_cart
    Cart
      .includes(items: [product: [:translations, { cover_attachment: :blob }]])
      .find_by(user: current_user)
  end

  def find_address
    current_user.default_address || current_user.addresses.first
  end

  def order_params
    params.expect(
      order: [:address_id]
    )
  end
end
