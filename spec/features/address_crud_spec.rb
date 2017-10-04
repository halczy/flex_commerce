require 'rails_helper'

describe 'Customer Address CRUD', type: :feature do

  let(:customer) { FactoryGirl.create(:customer) }

  describe 'access to address list' do
    it 'returns address list when signned in' do
      feature_signin_as(customer)
      click_on 'Dashboard'
      click_on 'Address'
      expect(page.current_path).to eq(addresses_path)
    end

    it 'redirects to to sign in page' do
      visit addresses_path
      expect(page.current_path).to eq(signin_path)
    end
  end

  describe 'create' do
    before do
      @community = FactoryGirl.create(:community)
      @district = @community.parent
      @city = @district.parent
      @province = @city.parent
      feature_signin_as(customer)
      visit addresses_path
      click_on('New Address', match: :first)
    end

    it 'can create address' do
      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select(@province.name, from: 'provinces_select')
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Save Address'

      expect(page.current_path).to eq(addresses_path)
      expect(page).to have_content('Test Recipient')
      expect(page).to have_content("#{@province.name}Test Street Address")
      expect(page).to have_content('17612344321')
    end

    it 'can create address using dynamic address selector', js: true do
      begin
        fill_in 'address[recipient]', with: 'Test Recipient'
        fill_in 'address[contact_number]', with: '17612344321'
        select(@province.name, from: 'provinces_select')
        select(@city.name, from: 'cities_select')
        select(@district.name, from: 'districts_select')
        select(@community.name, from: 'communities_select')
        fill_in 'address[street]', with: 'Test Street'
        click_on 'Save Address'
      rescue Capybara::ElementNotFound
        retry
      end

      expect(page.current_path).to eq(addresses_path)
      expect(page).to have_content('TEST RECIPIENT')
      expect(page).to have_content('17612344321')
      expect(page).to have_content(
        "#{@province.name}#{@city.name}#{@district.name}#{@community.name}Test Street"
      )
    end
  end

  describe 'edit' do
    before do
      @address = FactoryGirl.create(:address, addressable: customer)
      @province = Geo.find(@address.province_state)
      @city = Geo.find(@address.city)
      @district = Geo.find(@address.district)
      @community = Geo.find(@address.community)
      feature_signin_as(customer)
      visit addresses_path
    end

    it 'can access edit address path' do
      click_on("edit_#{@address.id}")
      expect(page.current_path).to eq(edit_address_path(@address))
    end

    it 'can edit address', js: true do
      begin
        visit addresses_path
        visit edit_address_path(@address)
        fill_in 'address[recipient]', with: 'Test Recipient'
        fill_in 'address[contact_number]', with: '17612344321'
        select(@province.name, from: 'provinces_select')
        select(@city.name, from: 'cities_select')
        fill_in 'address[street]', with: 'Test Street'
        click_on 'Save Address'
      rescue Capybara::ElementNotFound
        retry
      end

      expect(page.current_path).to eq(addresses_path)
      expect(page).to have_content('TEST RECIPIENT')
      expect(page).to have_content('17612344321')
      expect(page).to have_content(@address.reload.full_address)
    end
  end

  describe 'delete' do
    before do
      @address = FactoryGirl.create(:address, addressable: customer)
      feature_signin_as(customer)
      visit addresses_path
    end

    it 'can delete address' do
      click_on "confirm_del_#{@address.id}"
      expect(page).to have_content('Successfully deleted')
    end
  end



end
