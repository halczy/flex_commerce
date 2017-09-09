require 'rails_helper'

describe 'Shipping Method CRUD', type: :feature do

  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'create' do
    before do
      @province = FactoryGirl.create(:province)
      visit admin_shipping_methods_path
      click_on 'New Shipping Method'
    end

    it 'can create no shipping type shipping method' do
      fill_in 'shipping_method[name]', with: 'Test No Shipping'
      select 'No Shipping', from: 'shipping_method[variety]'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('Successfully created')
      expect(page).to have_content('Test No Shipping')
    end

    it 'can create delivery type shipping method', js: true do
      province_1 = FactoryGirl.create(:province)
      province_2 = FactoryGirl.create(:province)
      province_3 = FactoryGirl.create(:province)
      provinces = [ province_1, province_2, province_3,
                    province_1, province_2, province_3 ]
      rates = (1..6).to_a

      fill_in 'shipping_method[name]', with: 'Test Delivery'
      select 'Delivery', from: 'shipping_method[variety]'
      3.times { click_on 'Add Rate'}
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_geo_code"]').each do |el|
        el.set(provinces.shift.id)
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_init_rate"]').each do |el|
        el.set(rates.shift)
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_add_on_rate"]').each do |el|
        el.set(rates.shift)
      end
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('Successfully created')
      expect(page).to have_content('Test Delivery')
      provinces.each do |province|
        expect(page).to have_content(province.id)
        expect(page).to have_content(province.name)
      end
      6.times { |n| expect(page).to have_content("¥#{n+1}") }
    end

    it 'can create self pick up type shipping method', js: true do
      fill_in 'shipping_method[name]', with: 'Test Self Pickup'
      select 'Self Pickup', from: 'shipping_method[variety]'
      click_on 'Add Rate'
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_geo_code"]').each do |el|
        el.set('*')
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_init_rate"]').each do |el|
        el.set('0')
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_add_on_rate"]').each do |el|
        el.set('0')
      end
      fill_in 'shipping_method[addresses_attributes][0][recipient]', with: 'Test Recipient'
      fill_in 'shipping_method[addresses_attributes][0][contact_number]', with: '1234567890'
      select @province.name, from: 'shipping_method[addresses_attributes][0][province_state]'
      fill_in 'shipping_method[addresses_attributes][0][street]', with: 'Test Street Addr'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('*')
      expect(page).to have_content('¥0')
      expect(page).to have_content('Successfully created')
      expect(page).to have_content('Test Self Pickup')
      expect(page).to have_content('Test Recipient')
      expect(page).to have_content('1234567890')
      expect(page).to have_content(@province.name)
      expect(page).to have_content('Test Street Addr')
    end

    context 'error scenarios' do
      it 'renders error when name is not filled in' do
        select 'No Shipping', from: 'shipping_method[variety]'
        click_on 'Submit'
        expect(page).to have_css('#error_messages')
      end

      it 'renders error when geo code is not filled in', js: true do
        fill_in 'shipping_method[name]', with: 'Error Delivery'
        select 'Delivery', from: 'shipping_method[variety]'
        3.times { click_on 'Add Rate'}
        click_on 'Submit'
        expect(page).to have_css('#error_messages')
      end

      it 'renders error when address is incomplete' do
        fill_in 'shipping_method[name]', with: 'Error Self Pickup'
        select 'Self Pickup', from: 'shipping_method[variety]'
        click_on 'Submit'
        expect(page).to have_css('#error_messages')
      end
    end
  end

  describe 'edit' do
    it 'can change no shipping type method name'
    it 'can add/update/remove shipping rates'
    it 'can change self pick up address'
    context 'error scenarios' do
      it 'renders error when name is removed'
      it 'renders error when geo code alone is remove'
      it 'renders error if address is incomplete'
    end
  end

  describe 'destroy' do
    it 'can destory shipping method'
  end

end
