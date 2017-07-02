require 'rails_helper'

describe 'sign up as customer' do
  it 'allows sign up with email' do
    visit signup_path
    fill_in "user[ident]", with: "feature_test_user@example.com"
    fill_in "user[password]", with: "example"
    fill_in "user[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(user_path(User.last))
    expect(page).to have_selector('.alert-success')
    expect(page).to have_content('feature_test_user@example.com')
  end

  it 'allows sign up with cell number' do
    visit signup_path
    fill_in "user[ident]", with: "18398765432"
    fill_in "user[password]", with: "example"
    fill_in "user[password_confirmation]", with: "example"
    click_button 'Submit'

    expect(page.current_path).to eq(user_path(User.last))
    expect(page).to have_selector('.alert-success')
    expect(page).to have_content('18398765432')
  end

  it 'displays error messages when using invalid information' do
    visit signup_path
    click_button 'Submit'
    expect(page).to have_selector('#error_messages')
  end
end
