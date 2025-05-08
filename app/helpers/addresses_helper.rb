# frozen_string_literal: true

module AddressesHelper
  def select_country_options
    Country.all.map { [it.name, it.id] }
  end

  def select_state_options
    Country::State.all.map { [it.name, it.id] }
  end

  def default_country
    Country.find_by(name: 'México')
  end

  def default_state
    Country::State.find_by(name: 'Aguascalientes')
  end

  def select_cities_options
    Country::State::City.where(state: default_state).map { [it.name, it.id] }
  end

  def default_city
    Country::State::City.find_by(name: 'San José de Gracia')
  end
end

