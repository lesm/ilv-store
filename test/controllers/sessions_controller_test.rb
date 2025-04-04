# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user, email_address: 'mail@mail.com', password: 'password') }
  let(:valid_params) do
    { email_address: user.email_address, password: user.password }
  end
  let(:invalid_params) do
    { email_address: 'mail@mail.com', password: 'invalid' }
  end

  setup do
    Rails.cache.clear
  end

  describe '#new' do
    test 'returns success response' do
      get new_session_url

      assert_response :success
    end
  end

  describe '#create' do
    describe 'reaches rate limit' do
      test 'redirects to new session url' do
        10.times { post session_url, params: invalid_params }

        post session_url, params: valid_params
        assert_redirected_to new_session_url
      end
    end

    describe 'with valid params' do
      before { post session_url, params: valid_params }

      test 'creates a user session' do
        assert_equal(1, user.sessions.count)
      end

      test 'returns redirect response' do
        assert_response :redirect
      end
    end

    describe 'with invalid params' do
      before { post session_url, params: invalid_params }

      test 'does not create a user session' do
        assert_equal(0, user.sessions.count)
      end

      test 'returns redirect response' do
        assert_response :redirect
      end
    end
  end

  describe '#destroy' do
    before do
      authenticate_as(user)
    end

    test 'destroys the user session' do
      delete session_url

      assert_equal(0, user.sessions.count)
    end

    test 'returns redirect response' do
      delete session_url

      assert_response :redirect
    end
  end
end
