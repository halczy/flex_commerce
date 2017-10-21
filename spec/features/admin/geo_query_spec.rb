require 'rails_helper'

describe 'Geo Data Query', type: :feature do

  let(:admin) { FactoryBot.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'index page' do
    before do
      @country = FactoryBot.create(:country)
      @province = FactoryBot.create(:province)
      @city = FactoryBot.create(:city)
      @district = FactoryBot.create(:district)
      @community = FactoryBot.create(:community)
      visit admin_geos_path
    end

    it 'lists all geo data' do
      expect(page).to have_content(@community.name)
      expect(page).to have_content(@city.name)
      expect(page).to have_content(': 15')
    end

    it 'filters to display countries', js: true do
      select 'Country/Region'
      expect(page).to have_content(@country.name)
      expect(page).not_to have_content(@province.name)
    end

    it 'filters to display provinces', js: true do
      select 'Province/State'
      expect(page).to have_content(@province.name)
      expect(page).not_to have_content(@city.name)
    end

    it 'filters to display cities', js: true do
      select 'City'
      expect(page).to have_content(@city.name)
      expect(page).not_to have_content(@district.name)
    end

    it 'filters to display districts', js: true do
      select 'District'
      expect(page).to have_content(@district.name)
      expect(page).not_to have_content(@community.name)
    end

    it 'fitlers to display communities', js: true do
      select 'Community'
      expect(page).to have_content(@community.name)
      expect(page).not_to have_content(@district.name)
    end
  end

  describe 'search' do
    before do
      @illinois = FactoryBot.create(:province, id: '600000', name: 'Illinois')
      @rockford = FactoryBot.create(:city, id: '650000000000', name: 'Rockford', parent: @illinois)
      @evanston = FactoryBot.create(:city, id: '670000000000', name: 'Evanston', parent: @illinois)
    end

    it 'can search from index and return result at search page' do
      visit admin_geos_path
      fill_in 'search_term', with: "evan"
      click_on 'Search'
      expect(page.current_path).to eq(search_admin_geos_path)
      expect(page).to have_content(@evanston.name)
    end

    it 'can search from search page' do
      visit search_admin_geos_path
      fill_in 'search_term', with: '600000'
      click_on 'Search'
      expect(page).to have_content(@illinois.name)
      expect(page).to have_content(@rockford.name)
      expect(page).to have_content(@evanston.name)
    end

    it 'reutrns error messages when empty serach term is provided' do
      visit search_admin_geos_path
      fill_in 'search_term', with: ''
      click_on 'Search'
      expect(page).to have_content('provide a valid search term')
      expect(page).to have_content('No Matching')
    end
  end

end
