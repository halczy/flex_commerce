require 'rails_helper'

describe 'Product Inventories Management' do

  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

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
      begin
        click_on 'force delete.'
        within('#force_delete_inventories') { fill_in 'amount', with: 7 }
        sleep 2
      rescue Capybara::ElementNotFound => e
        sleep 2
      end
      evaluate_script 'document.getElementById("f_del_inv").submit();'

      expect(page).to have_content('Total (0)')
      expect(page).to have_css('.alert.alert-info')
    end

    it 'cannot remove more than destroyable prodcuts', js: true do
      click_on "#{@product_sold.name}"
      click_on 'Manage Inventories'
      click_on 'Delete Inventories'
      begin
        click_on 'force delete.'
        within('#force_delete_inventories') { fill_in 'amount', with: 5 }
        sleep 2
      rescue Capybara::ElementNotFound => e
        sleep 2
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
