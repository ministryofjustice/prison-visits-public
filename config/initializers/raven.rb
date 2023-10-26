sentry_dsn = Rails.configuration.sentry_dsn

if sentry_dsn
  require 'raven'

  Raven.configure do |config|
    config.processors -= [Raven::Processor::PostData]
    config.dsn = sentry_dsn
  end
else
  # (Rails logger is not initialized yet)
  $stdout.puts '[WARN] Sentry DSN is not set (SENTRY_DSN)'
end
