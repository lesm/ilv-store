# frozen_string_literal: true

require 'test_helper'

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  before do
    authenticate_as(create(:user, :with_default_address))
  end

  describe '#GET new' do
    test 'returns 200 status code' do
      get new_checkout_url
      assert_response :success
    end
  end
end
