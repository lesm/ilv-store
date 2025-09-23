# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order, only: %i[show]

  def index
    @orders = current_user.orders
                          .where.not(workflow_status: :draft)
                          .order(created_at: :desc)
  end

  def new
    @cart = find_cart
    @address = find_address
  end

  def show
    begin
      handle_redirect_from_stripe if params[:token].present?
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      # do nothing, just render the page as usual
    end

    request.variant = :drawer if drawer_request?

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

  def set_order
    @order = if params[:token].present?
               current_user.orders.find(params[:id])
             else
               current_user.orders
                           .includes(items: [product: [:translations, { cover_attachment: :blob }]])
                           .find(params[:id])
             end
  end

  def handle_successful_form_save
    session = create_stripe_checkout_session(@form.order)
    @form.order.update(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = "Try again, there was an error with the payment processor: #{e.message}"
    redirect_to @form.order
  end

  def create_stripe_checkout_session(order)
    token = Rails.application
                 .message_verifier(:from_stripe)
                 .generate({ order_id: order.id, user_id: current_user.id })

    Payment::Stripe::Checkout::Session.create(
      order:,
      success_url: order_url(order, token:),
      cancel_url: new_order_url(address_id: order.address.id)
    )
  end

  def build_form
    OrderForm.new(order_params.to_h).tap do |form|
      form.current_cart = current_cart
      form.current_user = current_user
    end
  end

  def handle_redirect_from_stripe
    data = Rails.application.message_verifier(:from_stripe).verify(params[:token])

    return unless data['order_id'] == params[:id]

    current_cart.clear
    redirect_to url_for(params.except(:token).permit!)
  end

  def find_cart
    Cart
      .includes(items: [product: [:translations, { cover_attachment: :blob }]])
      .find_by(user: current_user)
  end

  def find_address
    current_user.addresses.find_by(id: params[:address_id]) ||
      current_user.default_address || current_user.addresses.first
  end

  def order_params
    params.expect(
      order: [:address_id]
    )
  end
end
