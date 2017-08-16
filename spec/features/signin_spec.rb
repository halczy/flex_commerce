require 'rails_helper'

describe 'sign in as customer' do

  let(:customer) { FactoryGirl.create(:customer) }

  it 'allows sign in with email' do
    visit signin_path
    fill_in "session[ident]", with: customer.email
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.email)
  end

  it 'allows sign in with cell number' do
    visit signin_path
    fill_in "session[ident]", with: customer.cell_number
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.cell_number)
  end

  it 'displays error messages when using invalid information' do
    visit signin_path
    click_button 'Submit'

    expect(page).to have_css('.alert.alert-warning')
  end

  it 'redirects to previous page if sign in was prompted'
end

describe 'sign in as admin' do

  let(:admin) { FactoryGirl.create(:admin) }

  it 'redirects to admin dashboard' do
    visit signin_path
    fill_in "session[ident]", with: admin.email
    fill_in "session[password]", with: admin.password
    click_button 'Submit'

    expect(page.current_path).to eq(admin_dashboard_index_path)
  end

  it 'has link to admin dashboard from frontpage'
end
