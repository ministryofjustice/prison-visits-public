SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: ["'self'"],
    font_src: ["'self'", 'data:'],
    img_src: ["'self'", 'data:', 'www.google-analytics.com'],
    style_src: ["'self'"],
    script_src: [
      "'self'",
      'www.google-analytics.com',
      "'unsafe-eval'",
      "'sha256-+6WnXIl4mbFTCARd8N3COQmT3bJJmo32N8q8ZSQAIcU='",  # govuk
      "'sha256-G29/qSW/JHHANtFhlrZVDZW1HOkCDRc78ggbqwwIJ2g='",  # govuk
      "'sha256-9GTWoKmlaDM3V+GStWlXFaD4tf+wPfBN2ds2eySQ9aE='",  # govuk
      (Rails.env.test? ? "'unsafe-inline'" : '')
    ]
  }

  # So we can send JS errors to Sentry
  # Strip off leading <pub_key>@ and trailing /<proj_num> so we have a clean
  # domain name
  match = (Rails.configuration.sentry_dsn || '').match(%r{@(.+)\/})
  config.csp[:connect_src] = [match[1]] if match
end
