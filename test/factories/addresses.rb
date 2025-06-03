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
  end

  trait :mx do
    before(:create) do |address|
      address.country ||= Country.find_or_create_by(name: 'México', code: 'MX')
      address.state ||= Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX', country: address.country)
      address.city ||= Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state: address.state)
    end

    addressable { association :user }
    full_name { 'Juan Pérez' }
    street_and_number { 'Calle de los libres 107' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'Al lado del estacionamiento' }
  end
end
