# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :user
  belongs_to :country

  validates :state, :city, :postal_code, presence: true
end
