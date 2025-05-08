# frozen_string_literal: true

FactoryBot.define do
  factory :mx_postal_code do
    state { association(:country_state, :oaxaca) }
    city { association(:country_state_city, :oaxaca_de_juarez) }
    postal_code { '68_000' }
    neighborhood { 'Centro' }
  end
end
