require 'rails_helper'

describe 'sign in as customer' do
  
  let(:customer) { FactoryGirl.create(:customer) }

  before do
    visit root_path
    click_link 'Sign In'
  end

  it 'allows sign in with email' do
    fill_in "session[ident]", with: customer.email
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.email)
  end

  it 'allows sign in with cell number' do
    fill_in "session[ident]", with: customer.cell_number
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.cell_number)
  end
  
  it 'allows sign in with member id' do
    fill_in "session[ident]", with: customer.member_id
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.cell_number)
  end
  
  it 'allows sign in with dashed member id' do
    dashed_member_id = customer.member_id.to_s.insert(3, '-')
    fill_in "session[ident]", with: dashed_member_id
    fill_in "session[password]", with: customer.password
    click_button 'Submit'

    expect(page.current_path).to eq(customer_path(customer))
    expect(page).to have_content(customer.cell_number)
  end

  it 'displays error messages when using invalid information' do
    click_button 'Submit'

    expect(page).to have_css('.alert.alert-warning')
  end
  
  # TODO Switch to a better requested address
  it 'redirects to previous page if sign in was prompted' do
    visit "/customers/#{customer.id}"
    expect(page.current_path).to eq(signin_path)
    
    fill_in "session[ident]", with: customer.cell_number
    fill_in "session[password]", with: customer.password
    click_button 'Submit'
    
    expect(page.current_path).to eq(customer_path(customer))
  end
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

  it 'has link to admin dashboard from frontpage' do
    visit signin_path
    fill_in "session[ident]", with: admin.email
    fill_in "session[password]", with: admin.password
    click_button 'Submit'
    visit root_path
    
    expect(page).to have_content('Admin Dashboard')
  end
end

describe 'sign out' do
  let(:customer) { FactoryGirl.create(:customer) }
  let(:admin)    { FactoryGirl.create(:admin) }

  it 'signs out customer and return to the home page' do
    visit signin_path
    fill_in "session[ident]", with: customer.email
    fill_in "session[password]", with: customer.password
    click_button 'Submit'
    visit root_path
    click_link 'Sign Out'

    expect(page.current_path).to eq(root_path)
    expect(page).to have_css('.alert.alert-info')
    expect(page).to have_link('Sign In')
  end

  it 'signs out admin and return to the home page' do
    visit signin_path
    fill_in "session[ident]", with: admin.email
    fill_in "session[password]", with: admin.password
    click_button 'Submit'
    visit root_path
    click_link 'Sign Out'

    expect(page.current_path).to eq(root_path)
    expect(page).to have_css('.alert.alert-info')
    expect(page).to have_link('Sign Up')
  end
end
