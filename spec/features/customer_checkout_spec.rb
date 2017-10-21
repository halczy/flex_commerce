require 'rails_helper'

describe 'customer checkout process', type: :feature do

  let(:customer) { FactoryBot.create(:customer) }
  let(:cart)     { FactoryBot.create(:cart) }

  before do |example|
    unless example.metadata[:skip_before]
      create_placeholder_image
      @feature_cat = FactoryBot.create(:feature)
      @product = FactoryBot.create(:product)
      Categorization.create(product: @product, category: @feature_cat)
      3.times { FactoryBot.create(:inventory, product: @product) }
    end
  end


  context 'checkout as a signed in user' do
    it 'checks out the cart and redirects to shipping selection', skip_before: true do
      cart = FactoryBot.create(:cart, user: customer)
      3.times { cart.inventories << FactoryBot.create(:inventory, cart: cart) }
      feature_signin_as(customer)

      visit cart_path
      click_button 'Checkout'
      expect(page.current_path).to eq(shipping_order_path(Order.last))
    end
  end

  context 'checkout as guest' do
    it 'signs up then checkout' do
      visit root_url
      within("#product_#{@product.id}") do
        click_on 'Add to Cart'
      end
      click_button 'Checkout'
      expect(page.current_path).to eq(signin_path)

      click_on 'Sign Up'
      fill_in "customer[ident]", with: "checkout_test@example.com"
      fill_in "customer[password]", with: "example"
      fill_in "customer[password_confirmation]", with: "example"
      click_button 'Submit'
      expect(page.current_path).to eq(cart_path)

      click_button 'Checkout'
      expect(page.current_path).to eq(shipping_order_path(Order.last))
    end

    it 'signs in then checkout' do
      visit root_url
      within("#product_#{@product.id}") do
        click_on 'Add to Cart'
      end
      click_button 'Checkout'
      expect(page.current_path).to eq(signin_path)

      fill_in "session[ident]", with: customer.email
      fill_in "session[password]", with: customer.password
      click_button 'Submit'
      expect(page.current_path).to eq(cart_path)

      click_button 'Checkout'
      expect(page.current_path).to eq(shipping_order_path(Order.last))
    end
  end
end
