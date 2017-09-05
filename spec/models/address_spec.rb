require 'rails_helper'

RSpec.describe Address, type: :model do

  let(:address) { FactoryGirl.create(:address) }

  describe 'creation' do
    it 'can be created' do
      expect(address).to be_valid
    end

    context 'validation' do
      it 'cannot be created without recipient' do
        addr = FactoryGirl.build(:address, recipient: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without contact number' do
        addr = FactoryGirl.build(:address, contact_number: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without street address' do
        addr = FactoryGirl.build(:address, street: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without province_state' do
        expect {
          FactoryGirl.build(:address, province_state: nil)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

end
