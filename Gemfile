source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '~> 5.1'

gem 'excon'
gem 'high_voltage'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'phonelib'
gem 'puma', '3.9.1' # To test if production issues still happen with previous version
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
gem 'sentry-raven', '~> 2.7.0'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  ref: 'a264627211f2bf68f4e388200b2a050fe9081504'

gem 'email_address_validation',
  git: 'https://github.com/ministryofjustice/email_address_validation',
  ref: '6ba244a046b37bed02dca25271849513b200f056'

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
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
  gem 'uuid'
  gem 'rails-controller-testing'
  gem 'capybara-screenshot'
end
