# frozen_string_literal: true

require 'test_helper'

class CartsControllerTest < ActionDispatch::IntegrationTest
  before do
    authenticate_as(create(:user))
  end

  describe '#show' do
    test 'returns success response' do
      get cart_url

      assert_response :success
    end
  end
end
