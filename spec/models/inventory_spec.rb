require 'rails_helper'

RSpec.describe Inventory, type: :model do

  let(:product)         { FactoryBot.create(:product) }
  let(:inventory)       { FactoryBot.create(:inventory) }
  let(:inv_in_cart)     { FactoryBot.create(:inventory, status: 1) }
  let(:inv_in_order)    { FactoryBot.create(:inventory, status: 2) }
  let(:inv_in_checkout) { FactoryBot.create(:inventory, status: 3) }
  let(:inv_sold)        { FactoryBot.create(:inventory, status: 4) }

  describe 'creation' do
    it 'can be created' do
      expect(inventory).to be_valid
    end
  end

  describe 'scope and enum' do
    before do
      @inv_0_1 = FactoryBot.create(:inventory, product: product)
      @inv_0_2 = FactoryBot.create(:inventory, product: product)
      @inv_1_1 = FactoryBot.create(:inventory, product: product, status: 1)
      @inv_2_1 = FactoryBot.create(:inventory, product: product, status: 2)
      @inv_3_1 = FactoryBot.create(:inventory, product: product, status: 3)
      @inv_4_1 = FactoryBot.create(:inventory, product: product, status: 4)
      @inv_5_1 = FactoryBot.create(:inventory, product: product, status: 5)
    end

    it '#available returns unsold inventories' do
      expect(product.inventories.available).to match_array([@inv_0_1, @inv_0_2])
    end

    it "unavailable returns inventories all modified products" do
      expect(product.inventories.unavailable).to match_array([@inv_1_1, @inv_2_1,
                                                              @inv_3_1, @inv_4_1,
                                                              @inv_5_1])
    end


    it '#destroyable returns unsold|in_cart|in_order inventories' do
      expect(product.inventories.destroyable).to match_array(
        [@inv_0_1, @inv_0_2, @inv_1_1, @inv_2_1]
      )
    end

    it '#undestroyable returns in_checkout|sold|returned inventories' do
      expect(product.inventories.undestroyable).to match_array(
        [@inv_3_1, @inv_4_1, @inv_5_1]
      )
    end
  end

  describe '#restock' do
    it 'resets status for in cart inventory' do
      inv_in_cart.restock
      expect(inv_in_cart.unsold?).to be_truthy
      expect(inv_in_cart.cart).to be_nil
    end

    it 'resets status for in order inventory' do
      inv_in_order.restock
      expect(inv_in_order.unsold?).to be_truthy
      expect(inv_in_order.order).to be_nil
      expect(inv_in_order.shipping_method).to be_nil
    end

    it 'raises error if try to restock inventory in checkout' do
      expect { inv_in_checkout.restock }.to raise_error(StandardError)
    end
  end
end
