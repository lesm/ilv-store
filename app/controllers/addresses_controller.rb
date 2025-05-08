# frozen_string_literal: true

class AddressesController < ApplicationController
  def index
    @addresses = current_user.addresses
  end

  def new
    request.variant = :drawer
    @address = Address.new
  end

  def create
    @address = MexicanAddress.new(address_params)
    @address.user = current_user

    if @address.save
      redirect_to addresses_path, notice: t('.success')
    else
      flash.now[:alert] = @address.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def address_params
    params.expect(
      address: %i[
        country_id postal_code state_id city_id neighborhood street_and_number reference full_name phone_number
      ]
    )
  end
end
