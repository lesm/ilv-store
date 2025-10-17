# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order, only: %i[show]

  def index
    @orders = current_user.orders
                          .includes(
                            address: %i[city state],
                            items: [product: [:translations, { cover_attachment: :blob }]]
                          )
                          .where.not(workflow_status: :draft)
                          .order(created_at: :desc)
  end

  def show
    # TODO: Create a controller to handle Stripe redirects

    handle_success_redirect_from_stripe if params[:token].present?
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    # do nothing, just render the page as usual
  end

  def new
    # TODO: Create a controller to handle Stripe redirects
    begin
      handle_cancel_redirect_from_stripe if params[:token].present?
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      # do nothing, just render the page as usual
    end

    @cart = find_cart
    @address = find_address
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
      cancel_url: new_order_url(address_id: order.address.id, token:)
    )
  end

  def build_form
    OrderForm.new(order_params.to_h).tap do |form|
      form.current_cart = current_cart
      form.current_user = current_user
    end
  end

  def handle_success_redirect_from_stripe
    data = Rails.application.message_verifier(:from_stripe).verify(params[:token])

    return unless data['order_id'] == params[:id]

    @order.workflow_status_pending! if @order.workflow_status_draft?

    current_cart.clear
    redirect_to order_path(@order), notice: t('.payment_success')
  end

  def handle_cancel_redirect_from_stripe
    data = Rails.application.message_verifier(:from_stripe).verify(params[:token])
    order = current_user.orders.find_by(id: data['order_id'])

    return unless order

    order.cancel_stock_reservations! if order.workflow_status_draft?
    redirect_to new_order_path(address_id: order.address.id)
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
