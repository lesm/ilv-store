# frozen_string_literal: true

require 'test_helper'

class CartTest < ActiveSupport::TestCase
  let(:cart) { build(:cart) }

  test 'builds a valid cart' do
    assert cart.valid?
  end
end
