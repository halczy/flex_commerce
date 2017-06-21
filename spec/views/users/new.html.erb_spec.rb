require 'rails_helper'

RSpec.describe 'users/new' do

  it 'renders the sign up page with current dom elements' do
    @user = User.new
    render
    expect(rendered).to have_selector("#sign_up_title")
    expect(rendered).to have_selector('input[name="user[ident]"]')
    expect(rendered).to have_selector('input[name="user[password]"]')
    expect(rendered).to have_selector('input[name="user[password_confirmation]"]')
    expect(rendered).to have_selector('input[type="submit"]')
  end
end
