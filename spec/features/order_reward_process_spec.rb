require 'rails_helper'

describe 'customer order reward process', type: :feature do

  let(:customer) { FactoryBot.create(:wealthy_customer) }
  let(:referer)  { FactoryBot.create(:customer) }

  before do
    feature_signin_as customer
    @product =  FactoryBot.create(:product, price_reward: 100.to_money,
                                             reward: true, purchase_ready: true)
    visit product_path(@product)
    click_on 'Add to Cart'
    click_on 'Checkout'
    select 'Self Pickup', from: 'order_products_attributes_0_shipping_methods'
    click_on 'Next'
    click_on 'Next'
    click_on 'Confirm Order'
  end

  context 'referral reward' do
    it 'rewards referer if customer has a referer' do
      Referral.create(referer: referer, referee: customer)
      click_on 'Pay with Wallet'
      feature_signin_as referer
      visit reward_path(referer)
      expect(page).to have_content("Note: Referral reward")
    end

    it 'does not reward referer if customer has no referer' do
      click_on 'Pay with Wallet'
      visit reward_path(customer)
      expect(page).not_to have_content("Referral reward")
    end
  end

  context 'cash back reward' do
    it 'rewards cash back to referer' do
      Referral.create(referer: referer, referee: customer)
      click_on 'Pay with Wallet'
      feature_signin_as referer
      visit reward_path(referer)
      expect(page).to have_content("Note: Cash back reward")
    end

    it 'rewards cash back to customer' do
      FactoryBot.create(:service_order, user: customer, completed: true)
      Referral.create(referer: referer, referee: customer)
      click_on 'Pay with Wallet'
      visit reward_path(customer)
      expect(page).to have_content("Note: Cash back reward")
    end
  end
end
