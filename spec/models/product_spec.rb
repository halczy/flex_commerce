require 'rails_helper'

RSpec.describe Product, type: :model do

  let(:product) { FactoryGirl.create(:product) }

  describe 'creation' do
    it 'can be created' do
      expect(product).to be_valid
    end
  end

  describe 'validation' do
    it 'requires product to have a name' do
      no_name = FactoryGirl.build(:product, name: nil)
      no_name.valid?
      expect(no_name.errors.messages[:name]).to be_present
    end

    it 'requires product name to be shorter than 31 characters' do
      long_name = FactoryGirl.build(:product, name: "#{'x' * 31}")
      long_name.valid?
      expect(long_name.errors.messages[:name]).to be_present
    end

    it 'requires product to have a positive value' do
      neg_price_market = FactoryGirl.build(:product, price_market_cents: -100)
      neg_price_market.valid?
      expect(neg_price_market.errors.messages[:price_market]).to be_present
    end
  end
end
