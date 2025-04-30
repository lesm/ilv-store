# frozen_string_literal: true

require 'test_helper'

module Users
  class ThemePreferenceControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, theme_preference: 'light') }

    before do
      authenticate_as(user)
    end

    describe '#update' do
      test 'changes theme preference to dark' do
        put theme_preference_url
        assert_equal 'dark', user.reload.theme_preference
      end

      test 'changes theme preference to light' do
        user.update(theme_preference: 'dark')
        put theme_preference_url
        assert_equal 'light', user.reload.theme_preference
      end

      test 'returns redirect response' do
        put theme_preference_url

        assert_redirected_to root_url(locale: 'es')
      end
    end
  end
end
