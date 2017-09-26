require 'rails_helper'

describe 'customer order payment process', type: :feature do

  let(:customer) { FactoryGirl.create(:customer) }

  before do
    feature_signin_as customer
    @product = FactoryGirl.create(:product, purchase_ready: true)
    @province = Geo.find(@product.shipping_methods.delivery.first.shipping_rates.first.geo_code)
    visit product_path(@product)
    click_on 'Add to Cart'
    click_on 'Checkout'
    select 'Delivery', from: "order_products_attributes_0_shipping_methods"
    click_on 'Next'
    fill_in 'address[recipient]', with: 'Test Recipient'
    fill_in 'address[contact_number]', with: '17612344321'
    fill_in 'address[name]', with: 'Home'
    select @province.name, from: 'provinces_select'
    fill_in 'address[street]', with: 'Test Street Address'
    click_on 'Next'
  end

  context 'confirm order' do
    it 'confrims order and redirect to payment page' do
      click_on 'Confirm Order'

      expect(page).to have_content('Payment Summary')
      expect(page).to have_content('Amount Paid: ¥0')
      expect(page).to have_content('Order Status: Confirmed')
    end
  end

  context 'pay via wallet' do
  end

  context 'pay via alipay' do
  end

end
