source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2.3'

gem 'excon'
gem 'high_voltage'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'phonelib'
gem 'puma'
gem 'sass-rails', '~> 5.0'
gem 'govuk_template', '~> 0.17.0'
gem 'govuk_frontend_toolkit', '~> 4.6.1'
gem 'govuk_elements_rails', '~> 1.1.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Fixed version as workaround for Rails version 4.2 expecting method
# 'last_comment' to be defined. Review once we are using a different Rails
# version
gem 'rake', '< 11.0'
gem 'request_store'
# Fixed version as workaround for bug in 0.15.5
# https://github.com/getsentry/raven-ruby/issues/460
gem 'sentry-raven'
gem 'string_scrubber'
gem 'uglifier'
gem 'uri_template'
gem 'virtus'
gem 'zendesk_api'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'parser'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
end

group :test do
  gem 'capybara'
  gem 'fuubar'
  gem 'launchy'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
end
