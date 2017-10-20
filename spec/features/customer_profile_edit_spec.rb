require 'rails_helper'

describe 'customer profile edit' do

  let(:customer) { FactoryGirl.create(:customer) }

  before { feature_signin_as customer }

  context 'with valid params' do
    it 'updates profile with new records' do
      visit customer_path(customer)
      click_on 'Modify Profile'
      fill_in 'customer[name]', with: 'New Name'
      fill_in 'customer[cell_number]', with: '18612344321'
      fill_in 'customer[email]', with: 'new@email.com'
      fill_in 'customer[password]', with: 'newpassword'
      fill_in 'customer[password_confirmation]', with: 'newpassword'
      click_button 'Update Profile'

      expect(page).to have_content('updated successfully')
      expect(page).to have_content('New Name')
      expect(page).to have_content('18612344321')
      expect(page).to have_content('new@email.com')

      click_on 'Sign Out'
      visit signin_path
      fill_in 'session[ident]', with: 'new@email.com'
      fill_in 'session[password]', with: 'newpassword'
      click_button 'Submit'

      expect(page.current_path).to eq(dashboard_path(customer))
    end

    it 'sets referer if not previously set' do
      new_customer = FactoryGirl.create(:customer)
      visit customer_path(customer)
      click_on 'Modify Profile'
      fill_in 'customer[referer_id]', with: new_customer.id
      click_button 'Update Profile'

      expect(page).to have_content(new_customer.name)
    end
  end

  context 'with invalid params' do
    it 'rejects invalid email, cell_number, and password' do
      visit customer_path(customer)
      click_on 'Modify Profile'
      fill_in 'customer[cell_number]', with: '1'
      fill_in 'customer[email]', with: 'new@email'
      fill_in 'customer[password]', with: '1'
      fill_in 'customer[password_confirmation]', with: '1'
      click_button 'Update Profile'

      expect(page).to have_css('#error_messages')
      expect(page).to have_content('Cell Number is invalid')
      expect(page).to have_content('Email is invalid')
      expect(page).to have_content('Password is too short ')
    end

    it 'does not set referer if it already exist' do
      old_referer = FactoryGirl.create(:customer)
      new_referer = FactoryGirl.create(:customer)
      Referral.create!(referer: old_referer, referee: customer)

      visit customer_path(customer)
      click_on 'Modify Profile'
      fill_in 'customer[referer_id]', with: new_referer.id
      click_button 'Update Profile'

      expect(page).to have_content(old_referer.name)
    end
  end
end
