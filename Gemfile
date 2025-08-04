# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aws-sdk-s3', require: false
gem 'bcrypt'
gem 'faraday'
gem 'importmap-rails'
gem 'jbuilder'
gem 'mission_control-jobs'
gem 'pg', '~> 1.6'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.0.2'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'

gem 'csv'
gem 'roo'
gem 'roo-xls'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

gem 'bootsnap', require: false
gem 'kamal', require: false
gem 'thruster', require: false

gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'database_consistency', require: false
  gem 'letter_opener'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'minitest-spec-rails'
  gem 'mocha'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :tools do
  gem 'bundler-audit', require: false
  gem 'erb_lint', require: false
  gem 'htmlbeautifier', require: false
  gem 'memory_profiler', require: false
  gem 'ordinare', require: false
  gem 'rack-mini-profiler', require: false
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-packaging', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-thread_safety', require: false
  gem 'rubycritic', require: false
  gem 'ruby-lsp', require: false
  gem 'trace_location', require: false
end
