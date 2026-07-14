# frozen_string_literal: true

module AddressDefaultable
  extend ActiveSupport::Concern

  private

  def change_default_address(address)
    change_addresses_as_not_default
    address.update!(is_default: true)
  end

  def change_addresses_as_not_default
    current_user.addresses.where(is_default: true).update_all(is_default: false) # rubocop:disable Rails/SkipsModelValidations
  end

  def update_address(address, attributes)
    ActiveRecord::Base.transaction do
      change_addresses_as_not_default if address_as_default?(attributes)
      address.update!(attributes)
    end
  end

  def create_address(address, attributes)
    ActiveRecord::Base.transaction do
      change_addresses_as_not_default if address_as_default?(attributes)
      address.save!
    end
  end

  def address_as_default?(address_params)
    ActiveRecord::Type::Boolean.new.cast(address_params[:is_default])
  end
end
