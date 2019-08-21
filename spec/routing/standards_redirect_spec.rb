require 'rails_helper'

RSpec.describe 'redirects paths to meet standards', type: :request do
  # Following https://www.gov.uk/service-manual/technology/get-a-domain-name#ensure-users-start-their-journey-on-govuk
  it 'redirects the homepage' do
    get '/'
    expect(response).
      to redirect_to('/en/request')
  end
end
