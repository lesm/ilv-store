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
    request.variant = :drawer if turbo_frame_request?
    @order = current_user.orders
                         .includes(items: [product: [:translations, { cover_attachment: :blob }]])
                         .find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @form = build_form

    if @form.save
      handle_successful_form_save
    else
      flash.now[:alert] = @form.errors.full_messages.to_sentence
      @cart = find_cart
      @address = find_address
      render :new, status: :unprocessable_content
    end
  end

  private

  def handle_successful_form_save
    session = create_stripe_checkout_session(@form.order)
    @form.order.update(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = "Try again, there was an error with the payment processor: #{e.message}"
    redirect_to @form.order
  end

  def create_stripe_checkout_session(order)
    Payment::Stripe::Checkout::Session.create(
      order:,
      success_url: order_url(order),
      cancel_url: order_url(order)
    )
  end

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
