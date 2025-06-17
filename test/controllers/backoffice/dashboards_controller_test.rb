# frozen_string_literal: true

require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user) }

  describe '#show' do
    describe 'unauthenticated user' do
      test 'redirects to new_session_path' do
        get backoffice_dashboard_url

        assert_redirected_to new_session_path
      end
    end

    describe 'admin user' do
      test 'returns success response' do
        user.update(role: 'admin')
        authenticate_as(user)

        get backoffice_dashboard_url

        assert_response :success
      end
    end

    describe 'customer user' do
      test 'redirects to root_path' do
        user.update(role: 'customer')
        authenticate_as(user)

        get backoffice_dashboard_url

        assert_redirected_to root_path
      end
    end
  end
end
