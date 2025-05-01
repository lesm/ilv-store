# frozen_string_literal: true

require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  let(:country) { create(:country, name: 'México') }

  test 'builds a valid country' do
    assert build(:cart).valid?
  end

  test 'validates unique name' do
    country
    new_country = build(:country, name: 'México')

    assert new_country.invalid?
    assert new_country.errors[:name].include?('ya está en uso')
  end
end
