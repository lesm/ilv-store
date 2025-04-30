# frozen_string_literal: true

module Users
  class ThemePreferenceController < ApplicationController
    def update
      current_user.update(theme_preference:)

      redirect_to root_path
    end

    private

    def theme_preference
      current_user.theme_preference == 'dark' ? 'light' : 'dark'
    end
  end
end
