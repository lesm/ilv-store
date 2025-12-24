# frozen_string_literal: true

class Country
  class State
    class City < ApplicationRecord
      belongs_to :state
      has_many :mx_postal_codes, dependent: :restrict_with_error
      has_many :addresses, dependent: :restrict_with_error

      validates :name, presence: true, uniqueness: { scope: :state_id }
    end
  end
end
