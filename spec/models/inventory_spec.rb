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
      @inv_1 = FactoryGirl.create(:inventory, product: product)
      @inv_2 = FactoryGirl.create(:inventory, product: product)
    end

    it '#available returns unsold products' do
      expect(product.inventories.available).to match_array([@inv_1, @inv_2])
    end
  end
end
