# frozen_string_literal: true

class Country
  class State < ApplicationRecord
    belongs_to :country
    has_many :cities, dependent: :destroy
    has_many :mx_postal_codes, dependent: :restrict_with_error
    has_many :addresses, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: { scope: :country_id }
    validates :code, presence: true, uniqueness: { scope: :country_id }
  end
end
