# frozen_string_literal: true

FactoryBot.define do
  factory :mexican_address, class: 'MexicanAddress' do
    user
    country
    type { 'MexicanAddress' }
    state { association(:country_state, :oaxaca) }
    city { association(:country_state_city, state: state) }
    neighborhood { 'Centro' }
    street_level1 { 'Callejón Donají s/n' }
    street_level2 { nil }
    full_name { 'Luis Silva' }
    postal_code { '70760' }
    reference { 'Portón blanco' }
  end
end
