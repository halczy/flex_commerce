require 'rails_helper'

describe 'sign in as admin', type: :feature do
  let(:admin) { FactoryBot.create(:admin) }

  it 'redirects admin to admin dashboard upon sign in' do
    visit signin_path
    fill_in 'session[ident]', with: admin.email
    fill_in 'session[password]', with: 'example'
    click_button 'Submit'

    expect(page.current_path).to eq(admin_dashboard_index_path)
  end
end
