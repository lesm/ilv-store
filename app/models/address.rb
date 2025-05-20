# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :user
  belongs_to :country
  belongs_to :state, class_name: 'Country::State'
  belongs_to :city, class_name: 'Country::State::City'

  normalizes :street_level1, with: ->(value) { value.capitalize }

  validates :postal_code, :full_name, :street_level1, presence: true

  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true

  def short_summary
    "#{neighborhood}, #{postal_code}, #{city.name}, #{state.name}"
  end
end
