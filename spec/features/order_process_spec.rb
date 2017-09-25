require 'rails_helper'

describe 'customer order process', type: :feature do
  
  let(:customer) { FactoryGirl.create(:customer) }
  
  before do
    feature_signin_as customer
    @product_1 = FactoryGirl.create(:product, purchase_ready: true)
    @product_2 = FactoryGirl.create(:product, purchase_ready: true)
  end
  
  describe 'create order with product' do
    it "can create an order with an product" do
      visit product_path(@product_1)
      click_on 'Add to Cart'
      click_on 'Checkout'
      
      expect(page.current_path).to eq(shipping_order_path(Order.last))
      expect(page).to have_content(@product_1.name)
      expect(page).to have_select "order_products_attributes_0_shipping_methods", 
                       options: ['Delivery', 'Self Pickup', 'No Shipping']
    end
  end
  
  describe 'add shipping method to order' do
    it "can set self pickup as shipping method for order" do
      visit product_path(@product_1)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Self Pickup', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'
      
      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Self Pickup')
      expect(page).to have_content('Pickup at')
      expect(page).to have_content('Contact Number')
      expect(page).to have_content(@product_1.name)
    end
    
    xit "can set delivery as shipping method for order" do
      visit product_path(@product_1)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'
      
      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Delivery')
      expect(page).to have_content(@product_1.name)
      
      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select(Geo.province_state.first.name, from: 'provinces_select')
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'
      
      expect(page.current_path).to eq(review_order_path(Order.last))
      expect(Order.last.status).to eq('shipping_confirmed')
    end
    
  end
  
end