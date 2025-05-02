# frozen_string_literal: true

require 'test_helper'

class MexicanAddressTest < ActiveSupport::TestCase
  let(:mexican_address) { build(:mexican_address) }

  test 'builds a valid mexican address' do
    assert build(:mexican_address).valid?
  end

  describe '#validations' do
    test 'validates presence of area_level1' do
      mexican_address.area_level1 = nil

      assert mexican_address.invalid?
    end

    test 'validates presence of area_level2' do
      mexican_address.area_level2 = nil

      assert mexican_address.invalid?
    end

    test 'validates presence of street_level1' do
      mexican_address.street_level1 = nil

      assert mexican_address.invalid?
    end

    test 'validates presence of postal_code' do
      mexican_address.postal_code = nil

      assert mexican_address.invalid?
    end
  end
end
