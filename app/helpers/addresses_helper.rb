# frozen_string_literal: true

module AddressesHelper
  def select_country_options
    Country.all.map { [it.name, it.id] }
  end

  def default_country
    Country.find_by(name: 'México')
  end
end
