require 'rails_helper'

RSpec.describe Inventory, type: :model do

  let(:product) { FactoryGirl.create(:product) }
  let(:inventory) { FactoryGirl.create(:inventory) }

  describe 'creation' do
    it 'can be created' do
      expect(inventory).to be_valid
    end
  end
end
