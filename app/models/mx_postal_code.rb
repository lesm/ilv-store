# frozen_string_literal: true

class MxPostalCode < ApplicationRecord
  belongs_to :state, class_name: 'Country::State'
  belongs_to :city, class_name: 'Country::State::City'

  delegate :id, :name, to: :state, prefix: true
  delegate :id, :name, to: :city, prefix: true

  validates :postal_code, presence: true
  validates :neighborhood, presence: true, uniqueness: { scope: :postal_code }
end
