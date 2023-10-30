sentry_dsn = Rails.configuration.sentry_dsn

if sentry_dsn
  Sentry.init do |config|
    config.dsn = sentry_dsn
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
  end
else
  # (Rails logger is not initialized yet)
  $stdout.puts '[WARN] Sentry DSN is not set (SENTRY_DSN)'
end
