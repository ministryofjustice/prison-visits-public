SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: ["'self'"],
    font_src: ["'self'", 'data:'],
    img_src: ["'self'", 'data:', 'www.google-analytics.com'],
    style_src: ["'self'"],
    script_src: [
      "'self'",
      'www.google-analytics.com',
      ENV['RAVEN_JS_URL'],
      "'unsafe-eval'",
      "'sha256-+6WnXIl4mbFTCARd8N3COQmT3bJJmo32N8q8ZSQAIcU='",  # govuk
      "'sha256-G29/qSW/JHHANtFhlrZVDZW1HOkCDRc78ggbqwwIJ2g='",  # govuk
      "'sha256-9GTWoKmlaDM3V+GStWlXFaD4tf+wPfBN2ds2eySQ9aE='",  # govuk
      (Rails.env.test? ? "'unsafe-inline'" : '')
    ]
  }
end
