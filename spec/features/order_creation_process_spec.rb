require 'rails_helper'

describe 'customer order creation process', type: :feature do
  let(:customer) { FactoryGirl.create(:customer) }

  before do
    feature_signin_as customer
    @product = FactoryGirl.create(:product, purchase_ready: true)
    
    @s_method = @product.shipping_methods.delivery.first
    s_rate = @s_method.shipping_rates.sample
    @province = Geo.find(s_rate.geo_code)
  end

  describe 'create order with product' do
    it 'can create an order with an product' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'

      expect(page.current_path).to eq(shipping_order_path(Order.last))
      expect(page).to have_content(@product.name)
      expect(page).to have_select 'order_products_attributes_0_shipping_methods',
                                  options: ['Delivery', 'Self Pickup', 'No Shipping']
    end
  end

  describe 'add shipping method to order' do
    it 'can set self pickup as shipping method for order' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Self Pickup', from: 'order_products_attributes_0_shipping_methods'
      click_on 'Next'

      expect(page.current_path).to eq(address_order_path(Order.last))
      expect(page).to have_content('Self Pickup')
      expect(page).to have_content('Pickup at')
      expect(page).to have_content('Contact Number')
      expect(page).to have_content(@product.name)
    end

    it 'can set delivery as shipping method for order' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: 'order_products_attributes_0_shipping_methods'
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

    it 'saves address to customer when customer submit ship to new address' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Checkout'
      select 'Delivery', from: 'order_products_attributes_0_shipping_methods'
      click_on 'Next'

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
      select 'Delivery', from: 'order_products_attributes_0_shipping_methods'
      click_on 'Next'

      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select @province.name, from: 'provinces_select'
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'
      click_on 'Modify Address'
      click_on 'Modify Shipping'
      select 'Self Pickup', from: 'order_products_attributes_0_shipping_methods'
      click_on 'Next'

      expect(page).to have_content('Self Pickup')

      click_on 'Next'

      expect(page).to have_content('Self Pickup')
    end

    it 'can handle multiple products with different shipping method' do
      another_product = FactoryGirl.create(:product, purchase_ready: true)
      another_s_method = another_product.shipping_methods.self_pickup.first
      visit product_path(@product)
      click_on 'Add to Cart'
      visit product_path(another_product)
      click_on 'Add to Cart'
      click_on 'Checkout'

      find(%Q{option[value="#{@s_method.id}"]}).select_option
      find(%Q{option[value="#{another_s_method.id}"]}).select_option
      click_on 'Next'

      expect(page).to have_content('Delivery')
      expect(page).to have_content('Self Pickup')

      fill_in 'address[recipient]', with: 'Test Recipient'
      fill_in 'address[contact_number]', with: '17612344321'
      fill_in 'address[name]', with: 'Home'
      select @province.name, from: 'provinces_select'
      fill_in 'address[street]', with: 'Test Street Address'
      click_on 'Next'

      expect(page.current_path).to eq(review_order_path(Order.last))
      expect(page).to have_content('Self Pickup')
      expect(page).to have_content('Test Recipient')
    end

    context 'invalid submission' do
      it 'renders error message when customer submit empty address' do
        visit product_path(@product)
        click_on 'Add to Cart'
        click_on 'Checkout'
        select 'Delivery', from: 'order_products_attributes_0_shipping_methods'
        click_on 'Next'
        click_on 'Next'

        expect(page).to have_content('select an existing address')
        expect(page).to have_content('errors')
      end
    end
  end
end
