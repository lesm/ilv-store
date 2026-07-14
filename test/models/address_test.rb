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

    test 'allows only one default address per addressable' do
      user = create(:user)
      create(:address, :oxxo_bustamante, addressable: user, is_default: true)
      other_default = build(:address, :oxxo_llano, addressable: user, is_default: true)

      assert other_default.invalid?
      assert_includes other_default.errors.attribute_names, :is_default
    end

    test 'allows multiple non-default addresses per addressable' do
      user = create(:user)
      create(:address, :oxxo_bustamante, addressable: user, is_default: false)
      other_address = build(:address, :oxxo_llano, addressable: user, is_default: false)

      assert other_address.valid?
    end

    test 'allows the same default address to be re-saved' do
      address = create(:address, :oxxo_bustamante, is_default: true)

      assert address.valid?
    end

    test 'enforces uniqueness of default address at the database level' do
      user = create(:user)
      create(:address, :oxxo_bustamante, addressable: user, is_default: true)
      other_default = build(:address, :oxxo_llano, addressable: user, is_default: true)

      assert_raises(ActiveRecord::RecordNotUnique) { other_default.save!(validate: false) }
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
