sentry_js_dsn = Rails.configuration.sentry_js_dsn

if sentry_js_dsn
  require 'raven'

  Raven.configure do |config|
    config.dsn = sentry_js_dsn
  end
else
  # (Rails logger is not initialized yet)
  STDOUT.puts '[WARN] Sentry is not configured (SENTRY_JS_DSN)'
end
