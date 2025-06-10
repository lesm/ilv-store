# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  setup do
    WebMock.allow_net_connect!

    stub_request(:any, %r{https://us1.unione.io/})

    Rails.cache.clear
  end
end
