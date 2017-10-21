require 'rails_helper'

describe 'Shipping Method CRUD', type: :feature do

  let(:admin) { FactoryBot.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'create' do
    before do
      @province = FactoryBot.create(:province)
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
      province_1 = FactoryBot.create(:province)
      province_2 = FactoryBot.create(:province)
      province_3 = FactoryBot.create(:province)
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
      fill_in 'shipping_method[address_attributes][recipient]', with: 'Test Recipient'
      fill_in 'shipping_method[address_attributes][contact_number]', with: '1234567890'
      select @province.name, from: 'shipping_method[address_attributes][province_state]'
      fill_in 'shipping_method[address_attributes][street]', with: 'Test Street Addr'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('Successfully created')
      expect(page).to have_content('*')
      expect(page).to have_content('¥0')
      expect(page).to have_content('Test Self Pickup')
      expect(page).to have_content('Test Recipient')
      expect(page).to have_content('1234567890')
      expect(page).to have_content(@province.name)
      expect(page).to have_content('Test Street Addr')
    end

    context 'failing cases' do
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
    it 'can change no shipping type method name' do
      FactoryBot.create(:no_shipping)
      visit admin_shipping_methods_path
      click_on 'Edit'
      fill_in 'shipping_method[name]', with: 'Test New Name'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('Test New Name')
    end

    it 'can add shipping rates', js: true do
      field_num = 0
      delivery = FactoryBot.create(:delivery_sa)
      FactoryBot.create(:shipping_rate, geo_code: '1234', init_rate: 12,
                          add_on_rate: 34, shipping_method: delivery)
      city = FactoryBot.create(:city)

      visit admin_shipping_methods_path
      click_on 'Edit'
      click_on 'Add Rate'
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_geo_code"]').each do |el|
        el.set(city.id) if field_num == 1
        field_num += 1
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_init_rate"]').each do |el|
        el.set('33') if field_num == 3
        field_num += 1
      end
      page.all('input[id^="shipping_method_shipping_rates_attributes_"][id$="_add_on_rate"]').each do |el|
        el.set('7') if field_num == 5
        field_num += 1
      end
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content(city.name)
      expect(page).to have_content(city.id)
      expect(page).to have_content('¥33')
      expect(page).to have_content('¥7')
      expect(page).to have_content('1234')
      expect(page).to have_content('¥12')
      expect(page).to have_content('¥34')
    end

    it 'can update shipping rates' do
      delivery = FactoryBot.create(:delivery_sa)
      FactoryBot.create(:shipping_rate, geo_code: '1234', init_rate: 12,
                          add_on_rate: 34, shipping_method: delivery)
      city = FactoryBot.create(:city)

      visit admin_shipping_methods_path
      click_on 'Edit'
      fill_in 'shipping_method[shipping_rates_attributes][0][geo_code]', with: city.id
      fill_in 'shipping_method[shipping_rates_attributes][0][init_rate]', with: 66
      fill_in 'shipping_method[shipping_rates_attributes][0][add_on_rate]', with: 55
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content(city.id)
      expect(page).to have_content('¥66')
      expect(page).to have_content('¥55')
    end

    it 'can remove shipping rate', js: true do
      delivery = FactoryBot.create(:delivery_sa)
      FactoryBot.create(:shipping_rate, geo_code: '1234', init_rate: 12,
                          add_on_rate: 34, shipping_method: delivery)

      visit admin_shipping_methods_path
      click_on 'Edit'
      sleep 1
      click_on 'Remove'
      sleep 1
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).not_to have_content('1234')
      expect(page).not_to have_content('¥12')
      expect(page).not_to have_content('¥34')
    end

    it 'can change self pick up address', js: true do
      province = FactoryBot.create(:province)
      self_pickup = FactoryBot.create(:self_pickup_sa)
      FactoryBot.create(:address, addressable: self_pickup,
                                   province_state: province,
                                   country_region: nil,
                                   city: nil,
                                   district: nil,
                                   community: nil)
      visit admin_shipping_methods_path
      click_on 'Edit'
      fill_in 'shipping_method[address_attributes][recipient]', with: 'New Recipient'
      fill_in 'shipping_method[address_attributes][contact_number]', with: '1234567890'
      select province.name, from: 'shipping_method[address_attributes][province_state]'
      fill_in 'shipping_method[address_attributes][street]', with: 'Test Street Address'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_shipping_method_path(ShippingMethod.last))
      expect(page).to have_content('New Recipient')
      expect(page).to have_content('1234567890')
      expect(page).to have_content(province.name)
      expect(page).to have_content('Test Street Address')
    end

    context 'failing cases' do
      it 'renders error when name is removed' do
        FactoryBot.create(:no_shipping)
        visit admin_shipping_methods_path
        click_on 'Edit'
        fill_in 'shipping_method[name]', with: ''
        click_on 'Submit'

        expect(page).to have_css('#error_messages')
      end

      it 'renders error when geo code alone is remove' do
        delivery = FactoryBot.create(:delivery_sa)
        FactoryBot.create(:shipping_rate, geo_code: '1234', init_rate: 12,
                            add_on_rate: 34, shipping_method: delivery)

        visit admin_shipping_methods_path
        click_on 'Edit'
        fill_in 'shipping_method[shipping_rates_attributes][0][geo_code]', with: ''
        click_on 'Submit'

        expect(page).to have_css('#error_messages')
      end

      it 'renders error if address is incomplete' do
        province = FactoryBot.create(:province)
        self_pickup = FactoryBot.create(:self_pickup)
        FactoryBot.create(:address, addressable: self_pickup,
                                     province_state: province,
                                     country_region: nil,
                                     city: nil,
                                     district: nil,
                                     community: nil)
        visit admin_shipping_methods_path
        click_on 'Edit'
        fill_in 'shipping_method[address_attributes][recipient]', with: ''
        click_on 'Submit'

        expect(page).to have_css('#error_messages')
      end
    end
  end

  describe 'destroy' do
    it 'can destory shipping method' do
      FactoryBot.create(:no_shipping, name: 'some name')
      visit admin_shipping_methods_path
      click_on 'Delete'
      click_on 'Confirm'
      expect(page).to have_css('.alert-success')
      expect(page).not_to have_content('some name')
    end
  end

end
