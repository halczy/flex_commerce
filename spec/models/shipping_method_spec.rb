require 'rails_helper'

RSpec.describe ShippingMethod, type: :model do

  let(:shipping_method) { FactoryGirl.create(:shipping_method) }

  describe 'creation' do
    it 'can be created' do
      expect(shipping_method).to be_valid
    end

    it 'cannot be created without variety' do
      expect {
        FactoryGirl.create(:shipping_method, variety: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'relationships' do
    before do
      @product = FactoryGirl.create(:product)
      @shipping_delivery = FactoryGirl.create(:shipping_method)
      @shipping_self_pickup = FactoryGirl.create(:shipping_method, variety: 2)
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



end
