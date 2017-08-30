require 'rails_helper'

RSpec.describe Address, type: :model do

  let(:address) { FactoryGirl.create(:address) }

  describe 'creation' do
    it 'can be created' do
      expect(address).to be_valid
    end
  end

end
