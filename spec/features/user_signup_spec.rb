require 'rails_helper'

describe 'sign up as customer' do
  it 'allows sign up with email' do
    visit new_user_path
    fill_in "user_ident", with: "feature_test_user@example.com"
    fill_in "user_password", with: "example"
    fill_in "user_password_confirmation", with: "example"
    click_button "Sign Up"

    expect(page.current_path).to eq(user_path(User.last))
    expect(page).to have_content("feature_test_user@example.com")
  end

  it 'allows sign up with cell number' do
    visit new_user_path
    fill_in "user_ident", with: "18398765432"
    fill_in "user_password", with: "example"
    fill_in "user_password_confirmation", with: "example"
    click_button "Sign Up"

    expect(page.current_path).to eq(user_path(User.last))
    expect(page).to have_content("18398765432")
  end
end
