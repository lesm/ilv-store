# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  let(:country) { create(:country) }

  let(:params) do
    {
      user: {
        country_id: country.id,
        name: 'Luis Silva',
        email: 'mail@mail.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
  end

  before { country }

  describe '#GET new' do
    test 'returns success response' do
      get new_registration_url

      assert_response :success
    end
  end

  describe '#POST create' do
    before { stub_request(:any, %r{https://us1.unione.io/}) }

    describe 'with valid params' do
      test 'creates a user' do
        post registration_url, params: params

        assert_equal(1, User.count)
      end

      test 'delivers an email to verify email' do
        AccountMailerJob.expects(:perform_later).with(instance_of(String), :send_verify_email)

        post registration_url, params: params
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

      test 'returns unprocessable_content response' do
        post registration_url, params: params

        assert_response :unprocessable_content
      end
    end
  end
end
