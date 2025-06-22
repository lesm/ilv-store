# frozen_string_literal: true

module Orders
  class AddressesController < ApplicationController
    include AddressDefaultable

    def index
      @addresses = current_user.addresses
    end

    def update # rubocop:disable Metrics/MethodLength
      @address = current_user.addresses.find(params[:id])

      change_default_address(@address)

      respond_to do |format|
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.update(
              'orders-address', partial: 'orders/address', locals: { address: @address }
            )
          )
        end
      end
    end
  end
end
