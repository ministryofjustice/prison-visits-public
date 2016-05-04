require 'rails_helper'

RSpec.describe 'staff redirect', type: :request do
  it 'to pvb2 prison pages' do
    get '/en/prison/visits/123?a=b'
    expect(response).
      to redirect_to('http://localhost:3000/en/prison/visits/123?a=b')
  end

  it 'to pvb2 metrics pages' do
    get '/en/metrics/123'
    expect(response).
      to redirect_to('http://localhost:3000/en/metrics/123')
  end

  it 'to pvb2 staff pages' do
    get '/staff/example'
    expect(response).
      to redirect_to('http://localhost:3000/staff/example')
  end
end
