require 'rails_helper'

describe 'add product to shopping cart', type: :feature do

  let(:customer) { FactoryGirl.create(:customer) }

  before do
    create_placeholder_image
    @feature_cat = FactoryGirl.create(:feature)
    @brand = FactoryGirl.create(:brand)
    @product = FactoryGirl.create(:product)
    @product_oos = FactoryGirl.create(:product)
    Categorization.create(product: @product, category: @feature_cat)
    Categorization.create(product: @product_oos, category: @feature_cat)
    Categorization.create(product: @product, category: @brand)
    Categorization.create(product: @product_oos, category: @brand)
    3.times { FactoryGirl.create(:inventory, product: @product) }
  end

  describe 'front page' do
    context 'product in stock' do
      it 'adds to cart and redirects to shopping cart page as guest' do
        visit root_url
        within("#product_#{@product.id}") do
          click_on 'Add to Cart'
        end

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end

      it 'adds to cart and redirects to shopping cart page as customer' do
        feature_signin_as(customer)
        visit root_url
        within("#product_#{@product.id}") do
          click_on 'Add to Cart'
        end

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end
    end

    context 'product out of stock' do
      it 'show disabled out of stock button in place of add to cart button' do
        visit root_url
        within("#product_#{@product_oos.id}") do
          expect(page).to have_content('Out of Stock')
          click_on 'Out of Stock'
        end
        expect(page.current_path).to eq(root_path)
      end
    end
  end

  describe 'category product grid' do
    context 'product in stock' do
      it 'adds to cart and redirects to shopping cart page as guest' do
        visit category_path(@brand)
        within("#product_#{@product.id}") do
          click_on 'Add to Cart'
        end

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end

      it 'adds to cart and redirects to shopping cart page as customer' do
        feature_signin_as(customer)
        visit category_path(@brand)
        within("#product_#{@product.id}") do
          click_on 'Add to Cart'
        end

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end
    end

    context 'product out of stock' do
      it 'show disabled out of stock button in place of add to cart button' do
        visit category_path(@brand)
        within("#product_#{@product_oos.id}") do
          expect(page).to have_content('Out of Stock')
          click_on 'Out of Stock'
        end
        expect(page.current_path).to eq(category_path(@brand))
      end
    end
  end

  describe 'product detail page' do
    context 'product in stock' do
      it 'adds one inventory to cart as guest' do
        visit product_path(@product)
        click_on 'Add to Cart'

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end

      it 'adds one inventory to cart as customer' do
        feature_signin_as(customer)
        visit product_path(@product)
        click_on 'Add to Cart'

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
      end

      it 'adds multiple inventories to cart' do
        visit product_path(@product)
        fill_in "quantity", with: 2
        click_on 'Add to Cart'

        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
        expect(page).to have_field('quantity', with: 2)
      end

      it 'can toggle quantity to add to cart', js: true do
        visit product_path(@product)
        click_on '-'
        expect(page).to have_field('quantity', with: 1)
        2.times { click_on '+' }
        expect(page).to have_field('quantity', with: 3)
        click_on 'Add to Cart'
        expect(page.current_path).to eq(cart_path)
        expect(page).to have_content(@product.name)
        expect(page).to have_field('quantity', with: 3)
      end

      it 'cannot add more than available inventories to cart' do
        visit product_path(@product)
        fill_in "quantity", with: 20
        click_on 'Add to Cart'

        expect(page.current_path).to eq(product_path(@product))
        expect(page).to have_content('out of stock')
      end
    end

    context 'product out of stock' do
      it 'disabled add to cart button and have out of stock button in place' do
        visit product_path(@product_oos)
        expect(page).to have_content('Out of Stock')
        click_on('Out of Stock')
        expect(page.current_path).to eq(product_path(@product_oos))
      end
    end
  end

end
