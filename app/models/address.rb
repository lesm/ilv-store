# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :country
  belongs_to :state, class_name: 'Country::State'
  belongs_to :city, class_name: 'Country::State::City'

  normalizes :street_and_number, with: ->(value) { value.capitalize }

  validates :postal_code, :full_name, :street_and_number, presence: true

  validates :default, uniqueness: { scope: :addressable_id, if: -> { default? } }

  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true

  def short_summary
    "#{neighborhood}, #{postal_code}, #{city_name}, #{state_name}"
  end
end
