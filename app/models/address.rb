# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :user
  belongs_to :country

  validates :area_level1, :area_level2, :street_level1, :postal_code, presence: true
end
