# frozen_string_literal: true

require 'test_helper'

class MxPostalCodeTest < ActiveSupport::TestCase
  test 'builds a valid postal code' do
    assert build(:mx_postal_code).valid?
  end
end
