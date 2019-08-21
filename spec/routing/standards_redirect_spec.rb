require 'rails_helper'

RSpec.describe 'redirects paths to meet standards', type: :request do
  # Following https://www.gov.uk/service-manual/technology/get-a-domain-name#ensure-users-start-their-journey-on-govuk
  it 'redirects the homepage' do
    get '/'
    expect(response).
      to redirect_to('/en/request')
  end

  # Following https://ministryofjustice.github.io/security-guidance/contact/implement-security-txt/
  it 'redirects well-known security URL to MOJ\'s disclosure policy' do
    get '/.well_known/security.txt'
    expect(response).
      to redirect_to('https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt')
  end
end
