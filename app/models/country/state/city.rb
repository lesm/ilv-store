# frozen_string_literal: true

class Country
  class State
    class City < ApplicationRecord
      belongs_to :state

      validates :name, presence: true, uniqueness: { scope: :state_id }
    end
  end
end
