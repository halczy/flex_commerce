require 'rails_helper'

RSpec.describe Address, type: :model do

  let(:address)   { FactoryGirl.create(:address) }
  let(:province)  { FactoryGirl.create(:province) }
  let(:city)      { FactoryGirl.create(:city) }
  let(:district)  { FactoryGirl.create(:district) }
  let(:community) { FactoryGirl.create(:community) }

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

  describe '#build_full_address' do
    before do
      @address = FactoryGirl.create(:address, province_state: province.id,
                                              city: city.id,
                                              district: district.id,
                                              community: community.id)
    end

    it 'builds full address using all geo codes' do
      @address.build_full_address
      expect(@address.full_address).to eq(
        "#{province.name}#{city.name}#{district.name}#{community.name}#{@address.street}"
      )
    end

    it 'builds full addreess without full geo codes' do
      @address.district = nil; @address.community = nil
      @address.build_full_address
      expect(@address.full_address).to eq(
        "#{province.name}#{city.name}#{@address.street}"
      )
    end
  end

end
