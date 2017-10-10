require 'rails_helper'

describe 'order service process', type: :feature do

  let(:admin)          { FactoryGirl.create(:admin) }
  let(:custoemr)       { FactoryGirl.create(:customer) }
  let(:psuccess_order) { FactoryGirl.create(:payment_order, success: true) }
  let(:service_order)  { FactoryGirl.create(:service_order) }

  before { feature_signin_as admin }

  describe 'confirm order' do
    it 'can confirm orders after successful payment' do
      visit admin_order_path(psuccess_order)
      expect(page).to have_content('Confirm Order')
      click_on 'Confirm Order'
      expect(page).to have_content('Staff Confirmed')
    end
  end

  describe 'delivery order' do
    it 'can add shipping information' do
      visit admin_order_path(service_order)
      click_on 'Ship Order'
      fill_in 'shipping_company', with: 'ABCD'
      fill_in 'tracking_number', with: '12345'
      click_on 'Submit'

      expect(page).to have_content('Shipped')
      expect(page).to have_content("Shipped At " + Time.zone.now.strftime("%Y/%m/%d"))
    end

    it 'can confirm delivery order' do
      visit admin_order_path(service_order)
      click_on 'Ship Order'
      fill_in 'shipping_company', with: 'ABCD'
      fill_in 'tracking_number', with: '12345'
      click_on 'Submit'

      expect(page).to have_content('Mark as Shipping Completed')
      click_on('Mark as Shipping Completed')
      expect(page).to have_content('Shipped')
      expect(page).to have_content("Shipping Completed At " + Time.zone.now.strftime("%Y/%m/%d"))
    end
  end

  describe 'pickup order' do
    it 'can set order as ready for pickup' do
      visit admin_order_path(service_order)
      click_on 'Mark as Pickup Ready'

      expect(page).to have_content('Pickup Pending')
      expect(page).to have_content("Pickup Readied At " + Time.zone.now.strftime("%Y/%m/%d"))
    end

    it 'can mark order as picked up' do
      visit admin_order_path(service_order)
      click_on 'Mark as Pickup Ready'
      click_on 'Mark as Pickup Complete'

      expect(page).to have_content('Pickup Pending')
      expect(page).to have_content("Pickup Completed At " + Time.zone.now.strftime("%Y/%m/%d"))
    end
  end

  describe 'mix orders' do
    it 'marks order as completed when both delivery and pickup are done' do
      visit admin_order_path(service_order)
      click_on 'Ship Order'
      fill_in 'shipping_company', with: 'ABCD'
      fill_in 'tracking_number', with: '12345'
      click_on 'Submit'
      click_on('Mark as Shipping Completed')
      click_on 'Mark as Pickup Ready'
      click_on 'Mark as Pickup Complete'

      expect(page).to have_content('Status Completed')
    end
  end
end
