require 'rails_helper'

RSpec.feature 'not_found', :js do
  scenario 'catch all pages' do
    visit '/unknown'
    expect(page).to have_text('Not found')
  end
end
