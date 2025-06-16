# frozen_string_literal: true

require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user) }

  before do
    authenticate_as(user)
  end

  describe '#show' do
    test 'returns success response' do
      get backoffice_dashboard_url

      assert_response :success
    end
  end
end
