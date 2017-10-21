require 'rails_helper'

RSpec.describe Address, type: :model do

  let(:address)   { FactoryBot.create(:address) }
  let(:province)  { FactoryBot.create(:province) }
  let(:city)      { FactoryBot.create(:city) }
  let(:district)  { FactoryBot.create(:district) }
  let(:community) { FactoryBot.create(:community) }
  let(:customer)  { FactoryBot.create(:customer) }
  let(:order)     { FactoryBot.create(:order) }

  let(:order_delivery_selected) { FactoryBot.create(:order, selected: true,
                                                             only_delivery: true) }

  describe 'creation' do
    it 'can be created' do
      expect(address).to be_valid
    end

    context 'validation' do
      it 'cannot be created without recipient' do
        addr = FactoryBot.build(:address, recipient: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without contact number' do
        addr = FactoryBot.build(:address, contact_number: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without street address' do
        addr = FactoryBot.build(:address, street: nil)
        expect(addr).not_to be_valid
      end

      it 'cannot be created without province_state' do
        expect {
          FactoryBot.build(:address, province_state: nil)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#build_full_address' do
    before do
      @address = FactoryBot.create(:address, province_state: province.id,
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

  describe '#destroyable?' do
    it 'returns true if address is associated with customer' do
      customer_address = FactoryBot.create(:address, addressable: customer)
      expect(customer_address.destroyable?).to be_truthy
    end

    it 'returns true if address is standalone' do
      expect(address.destroyable?).to be_truthy
    end

    it 'returns false if address is associated with order' do
      order_address = FactoryBot.create(:address, addressable: order)
      expect(order_address.destroyable?).to be_falsey
    end
  end

  describe '#copy_to' do
    it 'returns duplicated address with belongs to the given object' do
      customer_address = FactoryBot.create(:address, addressable: customer)
      expect(customer_address.copy_to(order_delivery_selected)).to be_truthy
      order_address = Address.find_by(addressable_id: order_delivery_selected.id)
      expect(order_address).to be_an_instance_of(Address)
      expect(order_address.full_address).to eq(customer_address.full_address)
      expect(order_address.addressable).to eq(order_delivery_selected)
      expect(customer_address.addressable).to eq(customer)
    end
  end

  describe '#geo_codes' do
    it 'returns geo code from detail to broad' do
      result = address.geo_codes
      expect(result[0]).to eq(address.community)
      expect(result[1]).to eq(address.district)
      expect(result[2]).to eq(address.city)
      expect(result[3]).to eq(address.province_state)
    end

    it 'omits broken address chain' do
      broken_address = address.tap do |addr|
        addr.community = nil
        addr.city = nil
      end
      result = broken_address.geo_codes
      expect(result[0]).to eq(broken_address.district)
      expect(result[1]).to eq(broken_address.province_state)
    end
  end

end
