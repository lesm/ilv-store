# frozen_string_literal: true

class MexicanAddress < Address
  alias_attribute :street_and_number, :street_level1
end
