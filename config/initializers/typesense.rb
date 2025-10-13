# frozen_string_literal: true

require 'typesense'

if Rails.env.test?
  # Load mock client for test environment
  require Rails.root.join('lib/typesense_mock_client')
  TYPESENSE_CLIENT = TypesenseMockClient.new
else
  # Real Typesense client for development and production
  TYPESENSE_CLIENT = Typesense::Client.new(
    nodes: [
      {
        host: ENV.fetch('TYPESENSE_HOST', 'localhost'),
        port: ENV.fetch('TYPESENSE_PORT', '8108'),
        protocol: ENV.fetch('TYPESENSE_PROTOCOL', 'http')
      }
    ],
    api_key: ENV.fetch('TYPESENSE_API_KEY', 'xyz'),
    connection_timeout_seconds: 2
  )
end
