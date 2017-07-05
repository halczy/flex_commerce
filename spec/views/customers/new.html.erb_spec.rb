require 'rails_helper'

RSpec.describe 'customers/new' do

  it 'renders the sign up page with correct dom elements' do
    @customer = Customer.new
    render
    expect(rendered).to have_content(/Sign Up/)
    expect(rendered).to have_selector('input[name="customer[ident]"]')
    expect(rendered).to have_selector('input[name="customer[password]"]')
    expect(rendered).to have_selector('input[name="customer[password_confirmation]"]')
    expect(rendered).to have_selector('input[type="submit"]')
  end
end
