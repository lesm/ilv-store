# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'simplecov'
require 'rails/test_help'
require 'minitest/spec'
require 'mocha/minitest'

SimpleCov.start 'rails'

Dir[Rails.root.join('test/support/**/*.rb')].each { |file| require file }

module ActionDispatch
  class IntegrationTest
    include ::Integration::SessionHelper
  end
end

module ActiveSupport
  class TestCase
    extend Minitest::Spec::DSL
    include FactoryBot::Syntax::Methods
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do
      SimpleCov.result
    end
  end
end
