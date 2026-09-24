# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include System::SessionHelper

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_option|
    # CI installs Chrome via browser-actions/setup-chrome (see .github/workflows/ci.yml)
    # specifically to keep it paired with a matching ChromeDriver — but Selenium's own browser
    # discovery only probes a handful of hardcoded, well-known OS paths (e.g.
    # /opt/google/chrome/chrome on Debian/Ubuntu), not wherever that action actually installs
    # to, so left unset it silently launches whatever Chrome the runner image ships with
    # instead, version-mismatched against the ChromeDriver that action just set up
    # ("SessionNotCreatedError: this version of ChromeDriver only supports Chrome version X").
    # CHROME_PATH is exported by that workflow step; unset (and a no-op) everywhere else.
    driver_option.binary = ENV['CHROME_PATH'] if ENV['CHROME_PATH'].present?

    # CI (GitHub Actions, standard `CI=true`) runs as root, where Chrome's own sandbox init can
    # fail immediately, crashing on every launch with no more detail than "SessionNotCreatedError:
    # Chrome instance exited" (chromedriver only learns the process died, not why) — a no-op
    # locally. `--disable-dev-shm-usage` alongside it: GitHub-hosted runners' small /dev/shm is a
    # second, well-known cause of Chrome crashing under headless CI specifically.
    if ENV['CI'].present?
      driver_option.add_argument('--no-sandbox')
      driver_option.add_argument('--disable-dev-shm-usage')
    end
  end

  setup do
    WebMock.allow_net_connect!

    stub_request(:any, %r{https://us1.unione.io/})

    Rails.cache.clear
  end
end
