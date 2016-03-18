require 'rails_helper'

RSpec.feature 'Unsubscribe', js: true do
  scenario 'happy path' do
    visit unsubscribe_path(locale: 'en')
    expect(page).to have_text('Why did I receive this email?')
    expect(page).to have_text('because you requested a prison visit.')
  end
end
