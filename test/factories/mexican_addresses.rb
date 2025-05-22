# frozen_string_literal: true

FactoryBot.define do
  factory :mexican_address, class: 'MexicanAddress' do
    user
    type { 'MexicanAddress' }
    country { Country.find_or_create_by(name: 'México', code: 'MX') }
    state { Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX', country:) }
    city { Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state:) }
    neighborhood { 'Centro' }
    street_level1 { 'Callejón Donají s/n' }
    street_level2 { nil }
    full_name { 'Luis Silva' }
    postal_code { '70760' }
    reference { 'Portón blanco' }
  end

  trait :juan_perez_home do
    full_name { 'Juan Pérez' }
    street_level1 { 'Calle de los libres 107' }
    neighborhood { 'Oaxaca Centro' }
    postal_code { '68000' }
    reference { 'Al lado del estacionamiento' }
    user { association(:user) }
    country { Country.find_or_create_by(name: 'México', code: 'MX') }
    state { Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX') }
    city { Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state:) }
  end
end
