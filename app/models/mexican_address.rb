# frozen_string_literal: true

class MexicanAddress < Address
  alias_attribute :street_level1, :address_and_number
end
