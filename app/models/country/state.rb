# frozen_string_literal: true

class Country
  class State < ApplicationRecord
    belongs_to :country
    has_many :cities, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :country_id }
    validates :code, presence: true, uniqueness: { scope: :country_id }
  end
end
