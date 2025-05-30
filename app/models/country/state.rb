# frozen_string_literal: true

class Country
  class State < ApplicationRecord
    belongs_to :country
    has_many :cities, dependent: :destroy
  end
end
