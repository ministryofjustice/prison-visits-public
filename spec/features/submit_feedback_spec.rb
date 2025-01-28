require 'rails_helper'

RSpec.feature 'Submit feedback', :js do
  include FeaturesHelper

  # The body contains two fields which can vary:
  #
  # * referrer: The port changes from run to run
  # * user_agent: This differs between local machines and Circle CI
  #
end
