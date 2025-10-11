# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  let(:mx_address) { build(:address, :oxxo_bustamante) }

  test 'builds a valid mexican address' do
    assert build(:address, :oxxo_bustamante).valid?
  end

  describe '#validations' do
    test 'validates presence of state' do
      mx_address.state = nil

      assert mx_address.invalid?
    end

    test 'validates presence of city' do
      mx_address.city = nil

      assert mx_address.invalid?
    end

    test 'validates presence of street_and_number' do
      mx_address.street_and_number = nil

      assert mx_address.invalid?
    end

    test 'validates presence of full_name' do
      mx_address.full_name = nil

      assert mx_address.invalid?
    end

    test 'validates presence of postal_code' do
      mx_address.postal_code = nil

      assert mx_address.invalid?
    end
  end

  describe '#short_summary' do
    test 'returns a summary of the address' do
      expected_summary = "#{mx_address.neighborhood}, #{mx_address.postal_code}, " \
                         "#{mx_address.city.name}, #{mx_address.state.name}"
      assert_equal expected_summary, mx_address.short_summary
    end
  end
end
