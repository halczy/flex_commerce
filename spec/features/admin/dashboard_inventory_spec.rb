require 'rails_helper'

describe 'Admin Inventory Dashboard', type: :feature do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    feature_signin_as(admin)
    @unsold =       FactoryGirl.create(:inventory)
    @in_cart =      FactoryGirl.create(:inventory, status: 1)
    @in_order =     FactoryGirl.create(:inventory, status: 2)
    @in_checkout =  FactoryGirl.create(:inventory, status: 3)
    @sold =         FactoryGirl.create(:inventory, status: 4)
    @returned =     FactoryGirl.create(:inventory, status: 5)
    visit admin_inventories_path
  end

  describe 'visit inventories index' do

    it "show a list of available inventories" do
      expect(page).to have_content(@unsold.id)
      expect(page).to have_content(@unsold.product.name)
      expect(page).to have_content(@in_cart.id)
      expect(page).to have_content(@in_order.id)
      expect(page).to have_content(@in_checkout.id)
      expect(page).to have_content(@sold.id)
      expect(page).to have_content(@returned.id)
    end

    context 'filter' do
      it "returns only unsold inventories", js: true do
        select 'Unsold'
        expect(page).to have_content(@unsold.id)
        expect(page).not_to have_content(@in_cart.id)
      end

      it "returns only in cart inventories", js: true do
        select 'In Cart'
        expect(page).to have_content(@in_cart.id)
        expect(page).not_to have_content(@in_order.id)
      end

      it "returns only in checkout inventories", js: true do
        select 'In Checkout'
        expect(page).to have_content(@in_checkout.id)
        expect(page).not_to have_content(@sold.id)
      end

      it 'returns only sold inventories', js: true do
        select 'Sold'
        expect(page).to have_content(@sold.id)
        expect(page).not_to have_content(@returned.id)
      end

      it 'returns only returned inventories', js: true do
        select 'Returned'
        expect(page).to have_content(@returned.id)
        expect(page).not_to have_content(@unsold.id)
      end
    end
  end

  describe 'visit inventory detail page' do
    it 'navigates to details page and back to list' do
      click_on(@unsold.id)
      expect(page.current_path).to eq(admin_inventory_path(@unsold))

      click_on('Return to List')
      expect(page.current_path).to eq(admin_inventories_path)
    end

    it 'shows inventories properties' do
      click_on(@returned.id)

      expect(page).to have_content(@returned.id)
      expect(page).to have_content(@returned.status)
      expect(page).to have_content(@returned.product.id)
      expect(page).to have_content(@returned.product.name)
    end
  end
end
