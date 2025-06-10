# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  let(:user) do
    create(
      :user,
      email: 'mail@mail.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end
  let(:valid_params) { { email: 'mail@mail.com' } }
  let(:invalid_params) { { email: 'mail@mail' } }
  let(:token) { user.password_reset_token }

  describe '#new' do
    test 'returns success response' do
      get new_password_url

      assert_response :success
    end
  end

  describe '#create' do
    describe 'with valid params' do
      before do
        stub_request(:any, %r{https://us1.unione.io/})
      end

      test 'deliveries an email with password reset instructions' do
        EmailService.expects(:send_reset_password).with(user:)

        post passwords_url(token:), params: valid_params
      end

      test 'returns redirect response' do
        post passwords_url(token:), params: valid_params

        assert_response :redirect
      end
    end

    describe 'with invalid params' do
      test 'does not deliver an email with password reset instructions' do
        AccountMailer.expects(:with).with(user:).never

        post passwords_url(token:), params: invalid_params
      end

      test 'returns redirect response' do
        post passwords_url(token:), params: invalid_params

        assert_response :redirect
      end
    end
  end

  describe '#edit' do
    test 'returns success response' do
      get edit_password_url(token:)

      assert_response :success
    end

    describe 'with invalid token' do
      test 'redirects to new password url' do
        get edit_password_url(token: 'invalid')

        assert_redirected_to new_password_url
      end
    end
  end

  describe '#update' do
    let(:valid_params) do
      { password: 'new_password', password_confirmation: 'new_password' }
    end
    let(:invalid_params) do
      { password: 'new_password', password_confirmation: 'invalid' }
    end

    describe 'with valid params' do
      test 'redirects to new session url' do
        put password_url(token:), params: valid_params

        assert_redirected_to new_session_url
      end
    end

    describe 'with invalid params' do
      test 'redirects to edit password url' do
        put password_url(token:), params: invalid_params

        assert_redirected_to edit_password_url(token:)
      end
    end
  end
end
