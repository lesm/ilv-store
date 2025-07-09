# frozen_string_literal: true

require 'active_support/parameter_filter'

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]
  config.dsn = ENV.fetch('SENTRY_DSN', 'SENTRY_DSN')
  config.enabled_environments = ENV.fetch('SENTRY_ENABLED_ENVIRONMENTS', 'production').split(',')
  config.traces_sample_rate = 1.0

  config.send_default_pii = true

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

  config.before_send = lambda do |event, _hint|
    # Sanitize extra data
    event.extra = filter.filter(event.extra) if event.extra

    # Sanitize user data
    event.user = filter.filter(event.user) if event.user

    # Sanitize context data (if present)
    event.contexts = filter.filter(event.contexts) if event.contexts

    # Return the sanitized event object
    event
  end
end
