require 'rails_helper'

describe 'Admin Dashboard - Product', type: :feature do

  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'create' do
    before { visit admin_products_path }

    it 'can create product' do
      click_on('New Product')
      expect(page.current_path).to eq(new_admin_product_path)

      fill_in "product[name]", with: "Test Product Name"
      fill_in "product[tag_line]", with: "Test Product Tag Line"
      fill_in "product[sku]", with: "TESTSKU1234567890"
      select "True", from: "product[strict_inventory]"
      select "False", from: "product[digital]"
      first('input#introduction', visible: false).set("Test Introduction")
      first('input#description', visible: false).set("Test Description")
      first('input#specification', visible: false).set("Test Specification")
      fill_in "product[price_member]", with: "100.01"
      fill_in "product[price_reward]", with: "80.01"
      fill_in "product[price_market]", with: "120.01"
      fill_in "product[cost]", with: "50.01"
      click_on('Create Product')

      expect(page.current_path).to eq(admin_product_path(Product.last))
      expect(page).to have_content('Test Product Name')
      expect(page).to have_content('Test Product Tag Line')
      expect(page).to have_content('TESTSKU1234567890')
      expect(page).to have_content('Strict Inventory True')
      expect(page).to have_content('Digital Product False')
      expect(page).to have_content('Test Introduction')
      expect(page).to have_content('Test Description')
      expect(page).to have_content('Test Specification')
      expect(page).to have_content('¥100.01')
      expect(page).to have_content('¥80.01')
      expect(page).to have_content('¥120.01')
      expect(page).to have_content('¥50.01')
    end

    it 'can create product with categories' do
      cat_1 = FactoryGirl.create(:category)
      cat_2 = FactoryGirl.create(:category)
      special_cat = FactoryGirl.create(:category, flavor: 1)

      visit admin_products_path
      click_on('New Product')
      fill_in "product[name]", with: "Test Product with Categories"
      select "#{cat_1.name}", from: "reg_cat_sel"
      select "#{cat_2.name}", from: "reg_cat_sel"
      select "#{special_cat.name}", from: 'spc_cat_sel'
      click_on('Create Product')

      expect(page).to have_content("#{cat_1.name}")
      expect(page).to have_content("#{cat_2.name}")
      expect(page).to have_content("#{special_cat.name}")
    end

    it 'can create product with images attached' do
      click_on('New Product')
      fill_in "product[name]", with: "Test Product with Images"
      attach_file('product[images_attributes][0][image]', 'spec/support/files/img_1.jpeg')
      fill_in "product[images_attributes][0][title]", with: "Test Image 1"
      click_on('Create Product')
      expect(page).to have_content('Test Image 1')
      expect(page).to have_css('img')
    end

    context 'with invalid data' do
      it 'cannot create product with empty fields' do
        click_on('New Product')
        click_on('Create Product')
        expect(page).to have_css('#error_messages')
      end
    end
  end

  describe 'edit' do
    it 'can edit product'
    it 'can reassgin categories'
    it 'can attach new images'
    it 'can edit existing image properties'
  end

  describe 'delete' do
    it 'can delete product'
    it 'removes categories associations when product is removed'
    it 'removes associated images when product is deleted'
  end
end
