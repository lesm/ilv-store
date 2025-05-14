# frozen_string_literal: true

FactoryBot.define do
  factory :country_state_city, class: 'Country::State::City' do
    sequence(:name) { |n| "Oaxaca #{n}" }
    state { association(:country_state, :oaxaca) }
  end

  trait :oaxaca_de_juarez do
    name { 'Oaxaca de Juárez' }
    state { Country::State.find_or_create_by(name: 'Oaxaca', code: 'OAX') }
  end
end
