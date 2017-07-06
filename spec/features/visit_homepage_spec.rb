require 'rails_helper'

describe 'visit homepage as guest' do
  it 'renders sign in and sign up when not signed in' do
    visit root_path
    expect(page).to have_content('Sign In')
    expect(page).to have_content('Sign Up')
  end

  context 'fault tolerant' do
    let(:customer) { FactoryGirl.create(:customer) }

    before do
      visit signin_path
      fill_in 'session[ident]', with: customer.email
      fill_in 'session[password]', with: 'example'
      check('session[remember_me]')
      click_button 'Submit'
    end

    it 'does not generate error when session user_id is invalid' do
      User.delete(customer)
      visit root_path
      expect(page).to have_content('Sign In')
    end
  end


end
