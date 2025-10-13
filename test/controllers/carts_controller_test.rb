# frozen_string_literal: true

require 'test_helper'

class CartsControllerTest < ActionDispatch::IntegrationTest
  describe '#show' do
    describe 'when not authenticated' do
      test 'redirects to new session url' do
        get cart_url

        assert_redirected_to new_session_url
      end

      test 'renders turbo stream redirect when request is a turbo frame' do
        get cart_url, headers: { 'Turbo-Frame' => 'drawer' }

        assert_response :success
        assert_equal 'text/vnd.turbo-stream.html', response.media_type
        assert_match(/turbo-stream.*action="redirect"/, response.body)
      end
    end

    describe 'when authenticated' do
      before do
        authenticate_as(create(:user))
      end
      test 'returns success response' do
        get cart_url

        assert_response :success
      end
    end
  end
end
