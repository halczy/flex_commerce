require 'rails_helper'

RSpec.describe ShippingMethod, type: :model do

  let(:delivery)    { FactoryBot.create(:delivery) }
  let(:self_pickup) { FactoryBot.create(:self_pickup) }
  let(:no_shipping) { FactoryBot.create(:no_shipping) }
  let(:product)     { FactoryBot.create(:product) }
  let(:inventory)   { FactoryBot.create(:inventory) }

  describe 'creation' do
    it 'can be created' do
      expect(delivery).to be_valid
      expect(self_pickup).to be_valid
      expect(no_shipping).to be_valid
    end

    it 'cannot be created without variety' do
      expect {
        FactoryBot.create(:delivery, variety: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'relationships' do
    context 'product' do
      before do
        @product = FactoryBot.create(:product)
        @shipping_delivery = FactoryBot.create(:delivery)
        @shipping_self_pickup = FactoryBot.create(:self_pickup)
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

      # it 'returns false if digital delivery is not available to product' do
      #   expect(@product.shipping_methods.digital_delivery.present?).to be_falsey
      # end
    end

    context 'address' do
      before do
        @shipping_self_pickup = FactoryBot.create(:self_pickup)
      end

      it 'returns address that belongs to shipping method' do
        expect(@shipping_self_pickup.address).to be_present
      end
    end
  end

  describe '#destroyable?' do
    it 'returns true if it is not referred by any product or inventory' do
      expect(delivery.destroyable?).to be_truthy
    end

    it 'returns false if it is being referred by any products' do
      product.shipping_methods << delivery
      expect(delivery.destroyable?).to be_falsey
    end

    it 'return false if it is being referred to by any inventories' do
      FactoryBot.create(:inventory, shipping_method: self_pickup)
      expect(self_pickup.destroyable?).to be_falsey
    end
  end



end
