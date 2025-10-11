# frozen_string_literal: true

# Where the I18n library should search for translation file
I18n.load_path += Rails.root.glob('config/locales/**/*.yml')

# Permitted locales available for the application
I18n.available_locales = %i[es en]

# Set default locale to something other than :en
I18n.default_locale = :es
