require 'rails_helper'

describe 'customer order service process', type: :feature do

  let(:admin)          { FactoryGirl.create(:admin) }
  let(:psuccess_order) { FactoryGirl.create(:payment_order, success: true) }
  let(:service_order)  { FactoryGirl.create(:service_order) }

  before { feature_signin_as admin }

  describe 'confirm order' do
    it 'shows order as confrimed' do
      visit order_path(psuccess_order)
      expect(page).to have_content('Payment Success')
      visit admin_order_path(psuccess_order)
      click_on('Confirm Order')

      visit order_path(psuccess_order)
      expect(page).to have_content('Staff Confirmed')
    end
  end

  describe 'pickup process' do
    it 'shows order status as pickup pending with date' do
      visit order_path(service_order)
      expect(page).to have_content('Staff Confirmed')
      visit admin_order_path(service_order)
      click_on 'Mark as Pickup Ready'

      visit order_path(service_order)
      expect(page).to have_content('Pickup Pending')
      expect(page).to have_content("Pickup Readied At: " + DateTime.now.strftime("%Y/%m/%d"))
    end

    it 'displays pickup completion date' do
      visit admin_order_path(service_order)
      click_on 'Mark as Pickup Ready'
      click_on 'Mark as Pickup Complete'

      visit order_path(service_order)
      expect(page).to have_content('Pickup Completed At: ' + DateTime.now.strftime("%Y/%m/%d"))
    end
  end

  describe 'delivery process' do
    it 'show order status as shipped with date' do
      visit admin_order_path(service_order)
      click_on 'Ship Order'
      fill_in 'shipping_company', with: 'UPS'
      fill_in 'tracking_number', with: '1234567890'
      click_on 'Submit'

      visit order_path(service_order)
      expect(page).to have_content('UPS')
      expect(page).to have_content('1234567890')
      expect(page).to have_content('Shipped')
    end
  end

  describe 'mix order' do
    it 'displays order as completed ' do
      visit admin_order_path(service_order)
      click_on 'Ship Order'
      fill_in 'shipping_company', with: 'ABCD'
      fill_in 'tracking_number', with: '12345'
      click_on 'Submit'
      click_on('Mark as Shipping Completed')
      click_on 'Mark as Pickup Ready'
      click_on 'Mark as Pickup Complete'

      visit order_path(service_order)
      expect(page).to have_content('Order Status: Completed')
    end
  end
end
