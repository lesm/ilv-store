# frozen_string_literal: true

module Backoffice
  class OrdersController < BaseController
    before_action :set_order, only: %i[edit update send_in_transit_email]

    def index
      @orders = Order
                .includes(
                  :user,
                  address: %i[city state],
                  items: [product: [:translations, { cover_attachment: :blob }]]
                )
                .where.not(workflow_status: :draft)
                .order(created_at: :desc)
    end

    def edit
      request.variant = :drawer
    end

    def update
      if @order.update(order_params)
        flash[:notice] = t('.success')
        redirect_to backoffice_orders_path, status: :see_other
      else
        flash.now[:alert] = @order.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash'), status: :unprocessable_entity
      end
    end

    def send_in_transit_email
      if @order.for_in_transit_email?
        OrderMailerJob.perform_later(@order.id, :send_order_in_transit)
        @order.update(in_transit_email_sent_at: Time.current)
        flash[:notice] = t('.success')
      else
        flash[:alert] = t('.error')
      end

      redirect_to backoffice_orders_path, status: :see_other
    end

    private

    def set_order
      @order = current_user.orders.find(params[:id])
    end

    def order_params
      params.expect(order: %i[tracking_number carrier_name])
    end
  end
end
