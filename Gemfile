source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2.9'

gem 'excon'
gem 'high_voltage'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'phonelib'
gem 'puma'
gem 'sass-rails'
gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'govuk_elements_rails'
gem 'jquery-rails', '~> 4.2.0'
gem 'jquery-ui-rails', '~> 6.0.1'

# Fixed version as workaround for Rails version 4.2 expecting method
# 'last_comment' to be defined. Review once we are using a different Rails
# version
gem 'rake'
gem 'request_store'
# Fixed version as workaround for bug in 0.15.5
# https://github.com/getsentry/raven-ruby/issues/460
gem 'sentry-raven', '~> 2.5.3'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  ref: '639bd30e211846a0d76c1d869b376fa2b4c30568'

gem 'string_scrubber'
gem 'uglifier', '~> 2.7.2'
gem 'uri_template'
gem 'virtus'
gem 'zendesk_api'
gem 'secure_headers'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.6'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'awesome_print', require: 'ap'
end

group :test do
  gem 'capybara'
  gem 'fuubar'
  gem 'launchy'
  gem 'selenium-webdriver', '~> 3.4.4'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
  gem 'uuid'
end
