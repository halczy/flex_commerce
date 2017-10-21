require 'rails_helper'

describe 'sign up as customer', type: :feature do

  let(:customer) { FactoryBot.create(:customer) }

  it 'allows sign up with email' do
    visit signup_path
    fill_in "customer[ident]", with: "feature_test_user@example.com"
    fill_in "customer[password]", with: "example"
    fill_in "customer[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(dashboard_path(Customer.last))
    expect(page).to have_selector('.alert-success')
    click_on 'Profile'
    expect(page).to have_content('feature_test_user@example.com')
  end

  it 'allows sign up with cell number' do
    visit signup_path
    fill_in "customer[ident]", with: "18398765432"
    fill_in "customer[password]", with: "example"
    fill_in "customer[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(dashboard_path(Customer.last))
    expect(page).to have_selector('.alert-success')
    click_on 'Profile'
    expect(page).to have_content('18398765432')
  end

  it 'allows sign up via referral link' do
    visit "/r/#{customer.member_id}"
    expect(page.current_path).to eq(signup_path)

    fill_in "customer[ident]", with: "18398765432"
    fill_in "customer[password]", with: "example"
    fill_in "customer[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(customer.referees.count).to eq(1)
    expect(customer.referees.first.cell_number).to eq('18398765432')
  end

  it 'displays warning message when invalid referral link is used' do
    visit '/r/random-string'
    expect(page).to have_content('invalid')
  end

  it 'displays error messages when using invalid information' do
    visit signup_path
    click_button 'Submit'
    expect(page).to have_selector('#error_messages')
  end
end
