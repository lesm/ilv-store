# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    addressable { association :user }
    country { Country.find_or_create_by(name: 'México', code: 'MX') }
    state { Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX', country:) }
    city { Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state:) }
    neighborhood { 'Centro' }
    street_and_number { 'Callejón Donají s/n' }
    full_name { 'Luis Silva' }
    postal_code { '70760' }
    reference { 'Portón blanco' }
    default { false }
  end

  trait :oxxo_bustamante do
    before(:create) do |address|
      oaxaca_address(address:)
    end

    full_name { 'Juan Pérez' }
    street_and_number { 'Guerrero Y Colon 103, C. de Carlos María Bustamante' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'Al lado de GNC' }
  end

  trait :oxxo_llano do
    before(:create) do |address|
      oaxaca_address(address:)
    end

    full_name { 'Santiago Pérez' }
    street_and_number { 'Calle de José María Pino Suárez 800' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'En frente del parque el llano' }
  end

  trait :oxxo_santo_domingo do
    before(:create) do |address|
      oaxaca_address(address:)
    end

    full_name { 'Mateo Pérez' }
    street_and_number { 'Ignacio Allende Y Mariano Abasolo 405' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'En frente del temple Santo Domingo' }
  end

  trait :oxxo_garcia_vigil do
    before(:create) do |address|
      oaxaca_address(address:)
    end

    full_name { 'Valentina Pérez' }
    street_and_number { 'Garcia Vigil Y Porfirio Diaz 205' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'Al lado de la panadería la Bamby' }
  end
end

def oaxaca_address(address:)
  address.country ||= Country.find_or_create_by(name: 'México', code: 'MX')
  address.state ||= Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX', country: address.country)
  address.city ||= Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state: address.state)
end
