# frozen_string_literal: true

module Backoffice
  class OrdersController < BaseController
    def index
      @orders = current_user.orders
                            .includes(
                              address: %i[city state],
                              items: [product: [:translations, { cover_attachment: :blob }]]
                            )
                            .where.not(workflow_status: :draft)
                            .order(created_at: :desc)
    end

    def edit
      request.variant = :drawer
      @order = current_user.orders.find(params[:id])
    end

    def update # rubocop:disable Metrics/AbcSize
      @order = current_user.orders.find(params[:id])

      if @order.update(order_params)
        flash[:notice] = t('.success')
        redirect_to backoffice_orders_path, status: :see_other
      else
        flash.now[:alert] = @order.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash'), status: :unprocessable_entity
      end
    end

    private

    def order_params
      params.expect(order: %i[tracking_number carrier_name])
    end
  end
end
