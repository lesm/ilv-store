# frozen_string_literal: true

class AddressesController < ApplicationController
  include AddressDefaultable

  def index
    @addresses = current_user.addresses.includes(%i[state city])
  end

  def new
    request.variant = :drawer
    @address = Address.new
  end

  def edit
    @address = current_user.addresses.includes(%i[state city]).find(params[:id])
    request.variant = :drawer
  end

  def create # rubocop:disable Metrics/AbcSize
    @address = Address.new(address_params).tap { it.addressable = current_user }

    begin
      if create_address(@address, address_params)
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, url_redirect)
      end
    rescue ActiveRecord::RecordInvalid
      flash.now[:alert] = @address.errors.full_messages.to_sentence
      render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    @address = current_user.addresses.find(params[:id])

    if update_address(@address, address_params)
      flash[:notice] = t('.success')
      render turbo_stream: turbo_stream.action(:redirect, addresses_path)
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = @address.errors.full_messages.to_sentence
    render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
  end

  private

  def url_redirect
    request.referer || addresses_path
  end

  def address_params
    params.expect(
      address: %i[
        country_id postal_code state_id city_id neighborhood street_and_number reference full_name phone_number default
      ]
    )
  end
end
