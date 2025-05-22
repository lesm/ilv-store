# frozen_string_literal: true

module Checkouts
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
            turbo_stream: turbo_stream.replace(
              'checkout-address', partial: 'checkouts/address', locals: { address: @address }
            )
          )
        end
      end
    end
  end
end
