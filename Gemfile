source 'https://rubygems.org'
#  Needed for Heroku
ruby '2.7.5'

gem 'rails', '6.0.6.1'

gem 'bootsnap', require: false
gem 'connection_pool'
gem 'email_address_validation',
    git: 'https://github.com/ministryofjustice/email_address_validation',
    ref: 'd37caea140a11bbb82f6abfbecef39fef78b97e8'
gem 'excon'
gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'high_voltage'
gem 'jquery-rails', '~> 4.4.0'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'kramdown'
gem 'net-http'
gem 'uri', '0.10.0'
gem 'lograge'
gem 'logstash-event'
gem 'phonelib'
gem 'puma'
gem 'faraday'
gem 'pvb-instrumentation',
    git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
    tag: 'v1.0.1'
gem 'rake'
gem 'request_store'
gem 'sassc-rails'
gem 'sentry-rails'
gem 'sprockets', '< 4'
gem 'string_scrubber'
gem 'turnout'
gem 'uglifier', '~> 4.2.0', require: false
gem 'uri_template'

group :developmemt do
  gem 'rubocop-govuk'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', '>= 5.0.4'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine', '~> 3.8.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 5.0'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'rubocop-rails'
  gem 'shoulda-matchers'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'fuubar'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'cuprite'
  gem 'simplecov'
  gem 'uuid'
  gem 'vcr'
  gem 'webmock'
end
