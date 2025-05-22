# frozen_string_literal: true

module AddressDefaultable
  extend ActiveSupport::Concern

  def change_default_address(address)
    ActiveRecord::Base.transaction do
      current_user.addresses.where(default: true).update_all(default: false) # rubocop:disable Rails/SkipsModelValidations
      address.update!(default: true)
    end
  end
end
