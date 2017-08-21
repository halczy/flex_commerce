require 'rails_helper'

RSpec.describe Inventory, type: :model do

  let(:product) { FactoryGirl.create(:product) }
  let(:inventory) { FactoryGirl.create(:inventory) }

  describe 'creation' do
    it 'can be created' do
      expect(inventory).to be_valid
    end
  end

  describe 'scope and enum' do
    before do
      @inv_0_1 = FactoryGirl.create(:inventory, product: product)
      @inv_0_2 = FactoryGirl.create(:inventory, product: product)
      @inv_1_1 = FactoryGirl.create(:inventory, product: product, status: 1)
      @inv_2_1 = FactoryGirl.create(:inventory, product: product, status: 2)
      @inv_3_1 = FactoryGirl.create(:inventory, product: product, status: 3)
      @inv_4_1 = FactoryGirl.create(:inventory, product: product, status: 4)
      @inv_5_1 = FactoryGirl.create(:inventory, product: product, status: 5)
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
end
