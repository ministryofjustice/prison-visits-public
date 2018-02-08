source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '~> 5.1'
gem 'active_model_attributes', # Delete when using Rails 5.2
  git: 'https://github.com/alan/active_model_attributes.git',
  ref: 'd690c5fd73bb3fec56a7e906cf014e0b4f41d31f'

gem 'connection_pool'
gem 'excon'
gem 'high_voltage'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'phonelib'
gem 'puma'
gem 'sass-rails', require: false
gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'govuk_elements_rails'
gem 'jquery-rails', '~> 4.2.0'
gem 'jquery-ui-rails', '~> 6.0.1'

gem 'rake'
gem 'request_store'
gem 'sentry-raven', '~> 2.7.2'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  ref: 'a264627211f2bf68f4e388200b2a050fe9081504'

gem 'email_address_validation',
  git: 'https://github.com/ministryofjustice/email_address_validation',
  ref: 'c19178437958c53fa41fcd54b4ecebe9f8e6a2cf'

gem 'string_scrubber'
gem 'uglifier', '~> 2.7.2', require: false
gem 'uri_template'
gem 'secure_headers'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine', '~> 2.9.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7'
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
  gem 'vcr'
  gem 'webmock'
  gem 'uuid'
  gem 'rails-controller-testing'
  gem 'capybara-screenshot'
end
