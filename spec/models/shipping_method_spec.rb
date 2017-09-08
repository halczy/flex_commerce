require 'rails_helper'

RSpec.describe ShippingMethod, type: :model do

  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:self_pickup) {FactoryGirl.create(:self_pickup) }
  let(:no_shipping) { FactoryGirl.create(:no_shipping) }

  describe 'creation' do
    it 'can be created' do
      expect(delivery).to be_valid
      expect(self_pickup).to be_valid
      expect(no_shipping).to be_valid
    end

    it 'cannot be created without variety' do
      expect {
        FactoryGirl.create(:delivery, variety: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'relationships' do
    context 'product' do
      before do
        @product = FactoryGirl.create(:product)
        @shipping_delivery = FactoryGirl.create(:delivery)
        @shipping_self_pickup = FactoryGirl.create(:self_pickup)
        @product.shipping_methods << @shipping_delivery
        @product.shipping_methods << @shipping_self_pickup
      end

      it 'returns shipping method from product' do
        expect(@product.shipping_methods).to match_array([@shipping_delivery,
                                                          @shipping_self_pickup])
      end

      it 'returns true if delivery is available to product as a shipping method' do
        expect(@product.shipping_methods.delivery.present?).to be_truthy
      end

      it 'returns true if self pickup is available to product as a shipping method' do
        expect(@product.shipping_methods.self_pickup.present?).to be_truthy
      end

      it 'returns false if digital delivery is not available to product' do
        expect(@product.shipping_methods.digital_delivery.present?).to be_falsey
      end
    end

    context 'address' do
      before do
        @shipping_self_pickup = FactoryGirl.create(:self_pickup)
        @address = FactoryGirl.create(:address, addressable: @shipping_self_pickup)
      end

      it 'returns address that belongs to shipping method' do
        expect(@shipping_self_pickup.address.first).to eq(@address)
      end
    end
  end



end
