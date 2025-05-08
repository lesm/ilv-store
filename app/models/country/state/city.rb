# frozen_string_literal: true

class Country
  class State
    class City < ApplicationRecord
      belongs_to :state
    end
  end
end
