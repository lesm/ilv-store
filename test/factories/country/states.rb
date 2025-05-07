# frozen_string_literal: true

FactoryBot.define do
  factory :country_state, class: 'Country::State' do
    sequence(:name) { |n| "Oaxaca de Juárez #{n}" }
    code { 'OAX' }
    country { association(:country, name: 'México', code: 'MX') }
  end

  trait :oaxaca do
    name { 'Oaxaca de Juárez' }
    code { 'OAX' }
    country { association(:country, name: 'México', code: 'MX') }
  end
end
