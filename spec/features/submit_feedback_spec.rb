require 'rails_helper'

RSpec.feature 'Submit feedback', js: true do
  include FeaturesHelper

  # The body contains two fields which can vary:
  #
  # * referrer: The port changes from run to run
  # * user_agent: This differs between local machines and Circle CI
  #
  # This matcher truncates these fields.
  normalised_body = lambda do |r1, r2|
    normalised = [r1.body, r2.body].map { |req|
      req.sub(/,"referrer":.+$/, '}')
    }

    normalised.first == normalised.last
  end

  custom_matchers = [:method, :uri, :host, :path, :valid_uuid, normalised_body]
end
