# frozen_string_literal: true

module AddressesHelper
  def select_country_options
    Country.all.map { [it.name, it.id] }
  end

  def default_country
    Country.find_by(name: 'México')
  end

  def select_neighborhood_options(postal_code)
    return [] if postal_code.blank?

    MxPostalCode.includes(:state, :city).where(postal_code:).map do
      [it.neighborhood, it.neighborhood]
    end
  end
end
