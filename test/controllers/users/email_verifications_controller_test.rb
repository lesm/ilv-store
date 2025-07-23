# frozen_string_literal: true

require 'test_helper'

module Users
  class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user) }

    describe '#GET show' do
      describe 'with a valid token' do
        before { get user_email_verification_url(token: user.email_verification_token) }

        test 'returns a redirect response' do
          assert_response :redirect
        end

        test 'returns a notice message' do
          assert_equal 'Tu correo electrónico ha sido verificado.', flash[:notice]
        end

        test 'updates the user as verified' do
          assert user.reload.verified
        end
      end

      describe 'with an invalid token' do
        before do
          token = user.email_verification_token

          travel_to 2.days.from_now do
            get user_email_verification_url(token:)
          end
        end

        test 'returns a redirect response' do
          assert_response :redirect
        end

        test 'returns an alert message' do
          assert_equal 'El token de verificación no es válido o ha expirado.', flash[:alert]
        end
      end
    end
  end
end
