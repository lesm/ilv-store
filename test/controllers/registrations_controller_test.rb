# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe '#new' do
    test 'returns success response' do
      get new_registration_url

      assert_response :success
    end
  end

  describe '#create' do
    describe 'with valid params' do
      let(:params) do
        { user: { email: 'mail@mail.com', password: 'password', password_confirmation: 'password' } }
      end

      test 'creates a user' do
        post registration_url, params: params

        assert_equal(1, User.count)
      end

      test 'returns redirect response' do
        post registration_url, params: params

        assert_response :redirect
      end
    end

    describe 'with invalid params' do
      let(:params) { { user: { email: nil, password: 'password', password_confirmation: 'password' } } }

      test 'does not create a user' do
        post registration_url, params: params

        assert_equal(0, User.count)
      end

      test 'returns unprocessable_entity response' do
        post registration_url, params: params

        assert_response :unprocessable_entity
      end
    end
  end
end
