require 'rails_helper'

RSpec.feature 'PVB1 old links', :js do
  before do skip 'Too slow' end

  it 'renders an appropiate message' do
    visit(pvb1_status_path(id: 'old-id'))

    expect(page).to have_text('Visit expired')
  end
end
