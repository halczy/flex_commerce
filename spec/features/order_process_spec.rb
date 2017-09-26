require 'rails_helper'

describe 'customer order process', type: :feature do

  let(:customer) { FactoryGirl.create(:customer) }

  before do
    feature_signin_as customer
    @product = FactoryGirl.create(:product, purchase_ready: true)
    @province = Geo.find(@product.shipping_methods.delivery.first.shipping_rates.first.geo_code)
  end

  describe 'create order with product' do
    it "can create an order with an product" do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'

      expect(page.current_path).to eq(shipping_order_path(Order.last))
      expect(page).to have_content(@product.name)
      expect(page).to have_select "order_products_attributes_0_shipping_methods",
                       options: ['Delivery', 'Self Pickup', 'No Shipping']
    end
  end

  describe 'add shipping method to order' do
    it "can set self pickup as shipping method for order" do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Self Pickup', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Self Pickup')
      expect(page).to have_content('Pickup at')
      expect(page).to have_content('Contact Number')
      expect(page).to have_content(@product.name)
    end

    it "can set delivery as shipping method for order" do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Delivery')
      expect(page).to have_content(@product.name)

      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select @province.name, from: 'provinces_select'
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'

      expect(page.current_path).to eq(review_order_path(Order.last))
      expect(Order.last.status).to eq('shipping_confirmed')
      expect(page).not_to have_content('Shipping Cost: ¥0')
      expect(page).to have_content('Ship To')
      expect(page).to have_content('Test Street Address')
    end

    it 'saves address to customer when customer submit ship to new address', js: true do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Delivery')
      expect(page).to have_content(@product.name.upcase)

      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select @province.name, from: 'provinces_select'
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'
      click_on 'Modify Address'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Test Recipient')
      expect(page).to have_content('17612344321')
    end

    it 'can modify shipping method after shipping method is set' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Delivery')
      expect(page).to have_content(@product.name)

      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select @province.name, from: 'provinces_select'
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'
      click_on 'Modify Address'
      click_on 'Modify Shipping'
      select 'Self Pickup', from: "order_products_attributes_0_shipping_methods"
      click_on 'Next'

      expect(page).to have_content('Self Pickup')

      click_on 'Next'
      expect(page).to have_content('Self Pickup')
    end
  end

end
