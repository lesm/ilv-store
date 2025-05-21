# frozen_string_literal: true

class AddressesController < ApplicationController
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
    @address = MexicanAddress.new(address_params)
    @address.user = current_user

    if @address.save
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

  def change_default_address(address)
    ActiveRecord::Base.transaction do
      current_user.addresses.where(default: true).update_all(default: false) # rubocop:disable Rails/SkipsModelValidations
      address.update!(default: true)
    end
  end

  def address_params
    params.expect(
      mexican_address: %i[
        country_id postal_code state_id city_id neighborhood street_and_number reference full_name phone_number default
      ]
    )
  end
end
