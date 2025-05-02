# frozen_string_literal: true

FactoryBot.define do
  factory :mexican_address, class: 'MexicanAddress' do
    user
    country
    type { 'MexicanAddress' }
    area_level1 { 'Oaxaca de Juárez' }
    area_level2 { 'Santo Domingo Tehuantepec' }
    street_level1 { 'Callejón Donají s/n' }
    street_level2 { nil }
    postal_code { '70760' }
    reference { 'Portón blanco' }
  end
end
