# frozen_string_literal: true

FactoryBot.define do
  factory :mx_postal_code do
    state { association(:country_state, :oaxaca) }
    city { association(:country_state_city, :oaxaca_de_juarez) }
    postal_code { '68000' }
    neighborhood { 'Centro' }
  end

  trait :oaxaca_centro do
    state { association(:country_state, :oaxaca) }
    city { Country::State::City.find_or_create_by(name: 'Oaxaca de Juárez', state:) }
    postal_code { '68000' }
    neighborhood { 'Centro' }
  end
end
