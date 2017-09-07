require 'rails_helper'

describe 'shopping cart control' do
  let(:customer) { FactoryGirl.create(:customer) }

  before do |example|
    unless example.metadata[:skip_before]
      create_placeholder_image
      @product = FactoryGirl.create(:product)
      3.times { FactoryGirl.create(:inventory, product: @product) }
    end
  end

  context 'access to shopping cart page', skip_before: true do
    it 'returns shopping cart page as guest' do
      visit cart_path
      expect(page).to have_content('Shopping Cart')
      expect(page).to have_content('EMPTY')
    end

    it 'returns shopping cart page as customer' do
      feature_signin_as(customer)
      visit cart_path
      expect(page).to have_content('Shopping Cart')
      expect(page).to have_content('EMPTY')
    end
  end

  context 'shopping cart retention' do
    it 'retains cart content after sign up' do
      visit product_path(@product)
      click_on 'Add to Cart'
      click_on 'Sign Up'
      fill_in "customer[ident]", with: "feature_test_user@example.com"
      fill_in "customer[password]", with: "example"
      fill_in "customer[password_confirmation]", with: "example"
      click_button 'Submit'

      visit cart_path
      expect(page).to have_content(@product.name)
    end

    it 'retains cart content after sign in' do
      visit product_path(@product)
      click_on 'Add to Cart'
      feature_signin_as(customer)
      visit cart_path
      expect(page).to have_content(@product.name)
    end

    it 'combines cart content after sign in' do
      feature_signin_as(customer)
      visit product_path(@product)
      click_on 'Add to Cart'           # Add to cart as signed in user

      click_on 'Sign Out'
      visit cart_path
      expect(page).to have_content('EMPTY')
      visit product_path(@product)
      click_on 'Add to Cart'          # Add to cart as guest

      feature_signin_as(customer)     # Sign in again
      visit cart_path

      expect(page).to have_content(@product.name)
      expect(page).to have_field('quantity', with: 2)
    end
  end

  context 'quantity control' do
    before do
      visit product_path(@product)
      click_on 'Add to Cart'
    end

    it 'can increase quantity using + toggle' do
      click_on '+'
      expect(page.current_path).to eq(cart_path)
      expect(page).to have_field('quantity', with: 2)
    end

    it 'can reduce quantity using - toggle' do
      click_on '+'
      click_on '-'
      expect(page.current_path).to eq(cart_path)
      expect(page).to have_field('quantity', with: 1)
    end

    it 'can update quantity by changing quantity field' do
      fill_in 'quantity', with: 3
      expect(page.current_path).to eq(cart_path)
      expect(page).to have_field('quantity', with: 3)
    end

    context 'not enough stock' do
      it 'cannot toggle to increase more than available' do
        3.times { click_on '+' }
        expect(page.current_path).to eq(cart_path)
        expect(page).to have_field('quantity', with: 3)
        expect(page).to have_content('does not have enough stock')
      end

      it 'cannot change quantity field to more than available', js: true do
        fill_in "quantity", with: 999
        click_on 'Back to top'
        expect(page.current_path).to eq(cart_path)
        expect(page).to have_field('quantity', with: 1)
        expect(page).to have_content('does not have enough stock')
      end
    end
  end

  context 'delete product form cart' do
    before do
      visit product_path(@product)
      click_on 'Add to Cart'
    end

    it 'deletes product from cart' do
      click_on 'Remove'
      within("#remove_#{@product.id}") do
        expect(page).to have_content(@product.name)
        click_on 'Confirm'
      end
      expect(page.current_path).to eq(cart_path)
      expect(page).to have_content('EMPTY')
    end
  end

end
