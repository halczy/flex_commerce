require 'rails_helper'

describe 'Admin Dashboard - Product', type: :feature do

  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'create' do
    before { visit admin_products_path }

    it 'renders the new product page' do
      click_on('New Product')
      expect(page.current_path).to eq(new_admin_product_path)
    end

    it 'can create product' do
      click_on('New Product')

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
      cat_1 =       FactoryGirl.create(:category)
      cat_2 =       FactoryGirl.create(:category)
      brand_cat =   FactoryGirl.create(:brand)
      special_cat = FactoryGirl.create(:feature)

      visit admin_products_path
      click_on('New Product')
      fill_in "product[name]", with: "Test Product with Categories"
      select "#{cat_1.name}", from: "reg_cat_sel"
      select "#{cat_2.name}", from: "reg_cat_sel"
      select "#{brand_cat.name}", from: 'brand_cat_sel'
      select "#{special_cat.name}", from: 'spc_cat_sel'
      click_on('Create Product')

      expect(page).to have_content("#{cat_1.name}")
      expect(page).to have_content("#{cat_2.name}")
      expect(page).to have_content("#{brand_cat.name}")
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
    before do
      @product = FactoryGirl.create(:product)
      @product.categorizations.create(category: FactoryGirl.create(:category))
      visit admin_products_path
    end

    it 'renders the edit product page' do
      click_on("edit_#{@product.id}")
      expect(page.current_path).to eq(edit_admin_product_path(@product))
    end

    it 'can edit product' do
      click_on("edit_#{@product.id}")

      fill_in "product[name]", with: "EDIT Product Name"
      fill_in "product[tag_line]", with: "EDIT Product Tag Line"
      fill_in "product[sku]", with: "TESTEDITSKU1234567890"
      select "False", from: "product[strict_inventory]"
      select "True", from: "product[digital]"
      first('input#introduction', visible: false).set("EDIT Test Introduction")
      first('input#description', visible: false).set("EDIT Test Description")
      first('input#specification', visible: false).set("EDIT Test Specification")
      fill_in "product[price_member]", with: "123.01"
      fill_in "product[price_reward]", with: "82.01"
      fill_in "product[price_market]", with: "119.01"
      fill_in "product[cost]", with: "50.11"
      click_on('Update Product')

      expect(page.current_path).to eq(admin_product_path(@product))
      expect(page).to have_content('EDIT Product Name')
      expect(page).to have_content('EDIT Product Tag Line')
      expect(page).to have_content('TESTEDITSKU1234567890')
      expect(page).to have_content('Strict Inventory False')
      expect(page).to have_content('Digital Product True')
      expect(page).to have_content('EDIT Test Introduction')
      expect(page).to have_content('EDIT Test Description')
      expect(page).to have_content('EDIT Test Specification')
      expect(page).to have_content('¥123.01')
      expect(page).to have_content('¥82.01')
      expect(page).to have_content('¥119.01')
      expect(page).to have_content('¥50.11')
    end

    it 'can reassgin categories' do
      @product.categories.first
      new_cat = FactoryGirl.create(:category)
      click_on("edit_#{@product.id}")
      select "#{new_cat.name}", from: "reg_cat_sel"
      click_on('Update Product')

      expect(page).to have_content(new_cat.name)
    end

    it 'can edit existing image properties' do
      click_on('New Product')
      fill_in "product[name]", with: "Test Product with Images"
      attach_file('product[images_attributes][0][image]', 'spec/support/files/img_1.jpeg')
      fill_in "product[images_attributes][0][title]", with: "Test Image 1"
      click_on('Create Product')

      visit admin_products_path
      product_e1 = Product.order(created_at: :desc).first
      click_on("edit_#{product_e1.id}")
      fill_in "product[images_attributes][0][title]", with: "EDIT Image 1"
      click_on('Update Product')

      expect(page).to have_content('EDIT Image 1')
    end

    context 'invalid edit' do
      it 'renders error messages' do
        click_on("edit_#{@product.id}")
        fill_in "product[name]", with: ""
        click_on('Update Product')

        expect(page).to have_css('#error_messages')
      end
    end
  end

  describe 'delete' do
    before do
      @product = FactoryGirl.create(:product)
      @category = FactoryGirl.create(:category)
      @image = FactoryGirl.create(:image, imageable_type: 'Product', imageable_id: @product.id)
      @product.categorizations.create(category: @category)
      visit admin_products_path
    end

    it 'can delete product' do
      click_on("btn_del_#{@product.id}")
      click_on("confirm_del_#{@product.id}")
      expect(page.current_path).to eq(admin_products_path)
      expect(page).not_to have_content(@product.name)
    end

    it 'removes categories associations when product is removed' do
      click_on("btn_del_#{@product.id}")
      click_on("confirm_del_#{@product.id}")
      expect(@category).to be_valid
      expect(@category.reload.products.count).to eq(0)
    end

    it 'removes associated images when product is deleted' do
      click_on("btn_del_#{@product.id}")
      click_on("confirm_del_#{@product.id}")
      expect{@image.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'show' do
    context 'images' do
      before do
        visit admin_products_path
        click_on('New Product')
        fill_in "product[name]", with: "Test Product with Images"
        attach_file('product[images_attributes][0][image]', 'spec/support/files/img_1.jpeg')
        fill_in "product[images_attributes][0][title]", with: "Test Image 1"
        click_on('Create Product')
      end

      it 'only show delete button for uploaded image' do
        expect(page).to have_content('Delete', count: 1)
      end

      it 'does not show delete button for image uploaded through editor' do
        product = Product.last
        product.images.first.update(source_channel: 1)
        visit admin_product_path(product)
        expect(page).not_to have_content('Delete')
      end
    end
  end

  describe 'filter' do
    before do
      @product_in_stock = FactoryGirl.create(:product)
      @product_oos = FactoryGirl.create(:product)
      FactoryGirl.create(:inventory, product: @product_in_stock)
      FactoryGirl.create(:inventory, product: @product_oos, status: 4)
      visit admin_products_path
    end

    it "does not filter products without params" do
      expect(page).to have_content(@product_in_stock.name)
      expect(page).to have_content(@product_oos.name)
    end

    it "does not filter products with empty display param", js: true do
      select 'No Filter'
      expect(page).to have_content(@product_in_stock.name)
      expect(page).to have_content(@product_oos.name)
    end

    it "filters to display only in stock proudcts", js: true do
      select 'In Stock'
      expect(page).to have_content(@product_in_stock.name)
      expect(page).not_to have_content(@product_oos.name)
    end

    it 'fitlers to display only out of stock products', js: true do
      select 'Out of Stock'
      expect(page).not_to have_content(@product_in_stock.name)
      expect(page).to have_content(@product_oos.name)
    end
  end

  describe 'inventory management' do
    before do
      @product_unsold = FactoryGirl.create(:product)
      @product_sold = FactoryGirl.create(:product)
      3.times { FactoryGirl.create(:inventory, product: @product_unsold) }
      4.times { FactoryGirl.create(:inventory, product: @product_unsold, status: 1) }
      2.times { FactoryGirl.create(:inventory, product: @product_sold) }
      3.times { FactoryGirl.create(:inventory, product: @product_sold, status: 5) }
      visit admin_products_path
    end

    it "displays all inventories" do
      click_on "#{@product_unsold.name}"
      click_on 'Manage Inventories'

      expect(page.current_path).to eq(inventories_admin_product_path(@product_unsold))
      expect(page).to have_content("Total (7)")
      expect(page).to have_content("Unsold (3)")
      expect(page).to have_content("In Cart (4)")
      expect(page).to have_content(@product_unsold.inventories.sample.id)
    end

    it "can add inventories" do
      click_on "#{@product_sold.name}"
      click_on 'Manage Inventories'
      click_on 'Add Inventories'
      within('#add_inventories') do
        fill_in 'amount', with: 10
        click_on 'Submit'
      end

      expect(page).to have_content('Total (15)')
      expect(page).to have_css(".alert.alert-success")
    end

    it "can remove inventories", js: true do
      click_on "#{@product_sold.name}"
      click_on 'Manage Inventories'
      click_on 'Delete Inventories'
      within('#delete_inventories') do
        fill_in 'amount', with: 2
      end
      # Workaround for Capybara submit button bug
      evaluate_script 'document.getElementById("del_inv").submit();'
      # element = find_by_id('del_inv')
      # Capybara::RackTest::Form.new(page.driver, element.native).submit(el: nil)

      expect(page).to have_css(".alert.alert-success")
      expect(page).to have_content('Total (3)')
      expect(page).to have_content('Returned (3)')
    end

    it 'cannot remove more than unsold products', js: true do
      click_on "#{@product_unsold.name}"
      click_on 'Manage Inventories'
      click_on 'Delete Inventories'
      within('#delete_inventories') do
        fill_in 'amount', with: 10
      end
      evaluate_script 'document.getElementById("del_inv").submit();'

      expect(page).to have_content('Total (7)')
      expect(page).to have_css(".alert.alert-danger")
    end

    it 'can force remove destroyable inventories', js: true do
      click_on "#{@product_unsold.name}"
      click_on 'Manage Inventories'
      click_on 'Delete Inventories'
      click_on 'force delete.'
      within('#force_delete_inventories') do
        fill_in 'amount', with: 7
      end
      evaluate_script 'document.getElementById("f_del_inv").submit();'

      expect(page).to have_content('Total (0)')
      expect(page).to have_css('.alert.alert-info')
    end

    it 'cannot remove more than destroyable prodcuts', js: true do
      click_on "#{@product_sold.name}"
      click_on 'Manage Inventories'
      click_on 'Delete Inventories'
      click_on 'force delete.'
      within('#force_delete_inventories') do
        fill_in 'amount', with: 5
      end
      evaluate_script 'document.getElementById("f_del_inv").submit();'

      expect(page).to have_content('Total (5)')
      expect(page).to have_css('.alert.alert-info')
    end

    it 'can delete individual product', js: true do
      unsold_inv = FactoryGirl.create(:inventory, product: @product_unsold)
      visit inventories_admin_product_path(@product_unsold)
      click_on("btn_del_#{unsold_inv.id}")
      within("#delete_#{unsold_inv.id}") do
        click_on('Confirm')
      end

      expect(page.current_path).to eq(inventories_admin_product_path(@product_unsold))
      expect(page).not_to have_content(unsold_inv.id)

    end
  end
end
