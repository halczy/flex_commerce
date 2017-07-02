require 'rails_helper'

describe 'sign up as customer' do
  it 'allows sign up with email' do
    visit signup_path
    fill_in "customer[ident]", with: "feature_test_user@example.com"
    fill_in "customer[password]", with: "example"
    fill_in "customer[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(Customer.last))
    expect(page).to have_selector('.alert-success')
    expect(page).to have_content('feature_test_user@example.com')
  end

  it 'allows sign up with cell number' do
    visit signup_path
    fill_in "customer[ident]", with: "18398765432"
    fill_in "customer[password]", with: "example"
    fill_in "customer[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(Customer.last))
    expect(page).to have_selector('.alert-success')
    expect(page).to have_content('18398765432')
  end

  it 'displays error messages when using invalid information' do
    visit signup_path
    click_button 'Submit'
    expect(page).to have_selector('#error_messages')
  end
end
