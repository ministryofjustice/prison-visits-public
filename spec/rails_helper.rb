ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'capybara/rspec'
require 'webmock/rspec'
require 'capybara-screenshot/rspec'
require 'resolv'

Dir[Rails.root.join('spec/support/features/*.rb')].sort.each { |f| require f }

WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)


Capybara.default_max_wait_time = 10
Capybara.asset_host = 'http://localhost:4000'
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.include ActiveSupport::Testing::TimeHelpers

  config.infer_spec_type_from_file_location!

  config.before do
    I18n.locale = I18n.default_locale
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
