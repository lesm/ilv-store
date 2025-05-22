# frozen_string_literal: true

class AddressesController < ApplicationController
  include AddressDefaultable

  def index
    @addresses = current_user.addresses
  end

  def new
    request.variant = :drawer
    @address = MexicanAddress.new
  end

  def edit
    request.variant = :drawer
    @address = current_user.addresses.find(params[:id])
  end

  def create # rubocop:disable Metrics/AbcSize
    new_default_address = address_default?

    @address = MexicanAddress.new(address_params).tap { it.user = current_user }

    if @address.save
      change_default_address(@address) if new_default_address

      flash[:notice] = t('.success')
      render turbo_stream: turbo_stream.action(:redirect, addresses_path)
    else
      flash.now[:alert] = @address.errors.full_messages.to_sentence
      render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    @address = current_user.addresses.find(params[:id])

    change_default_address(@address) if address_default?

    if @address.update(address_params)
      flash[:notice] = t('.success')
      render turbo_stream: turbo_stream.action(:redirect, addresses_path)
    else
      flash.now[:alert] = @address.errors.full_messages.to_sentence
      render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
    end
  end

  private

  def address_default?
    value = params[:mexican_address].delete(:default)
    ActiveRecord::Type::Boolean.new.cast(value)
  end

  def address_params
    params.expect(
      mexican_address: %i[
        country_id postal_code state_id city_id neighborhood street_and_number reference full_name phone_number
      ]
    )
  end
end
