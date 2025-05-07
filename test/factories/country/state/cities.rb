# frozen_string_literal: true

FactoryBot.define do
  factory :country_state_city, class: 'Country::State::City' do
    sequence(:name) { |n| "Oaxaca #{n}" }
    state { association(:country_state, :oaxaca) }
  end
end
