require 'rails_helper'

RSpec.describe OrdersHelper, type: :helper do

  let(:order_delivery_selected) { FactoryGirl.create(:order, selected: true,
                                                             only_delivery: true) }
  let(:order_pickup_selected)   { FactoryGirl.create(:order, selected: true,
                                                             only_pickup: true) }
  let(:order_confrimed)         { FactoryGirl.create(:order, confirmed: true) }

  before do
    @order = FactoryGirl.create(:order, set: true)
    order_service = OrderService.new(order_id: @order)
    order_service.confirm
  end

  describe '#subtotal_by' do
    context 'shipping_confirmed_order' do
      it 'reutrns sum up purchase price of inventories given the product' do
        sample_product = order_delivery_selected.products.sample
        result = helper.subtotal_by(order_delivery_selected, sample_product)
        expect(result).to eq(sample_product.price_member)
      end
    end

    context 'confirmed order' do
      it 'returns sums up product price of inventories given the product' do
        sample_product = order_confrimed.products.sample
        result = helper.subtotal_by(order_confrimed, sample_product)
        expect(result).to eq(sample_product.price_member)
      end
    end

  end

  describe '#shipping_method_by' do
    it 'returns shipping method of the given product' do
      sample_product = order_delivery_selected.products.sample
      result = helper.shipping_method_by(order_delivery_selected, sample_product)
      expect(result).to eq('delivery')
    end
  end

  describe '#purchase_price_by' do
    it 'returns the purchase price of inventories by product' do
      sample_product = @order.products.sample
      result = helper.purchase_price_by(@order, sample_product)
      expect(result).to eq(sample_product.price_member)
    end
  end

  describe '#get_self_pickup_method' do
    it 'reutrns self pickup method from order' do
      result = helper.get_self_pickup_method(@order)
      expect(result.variety).to eq('self_pickup')
    end

    it 'returns nil if self pickup is not used in order' do
      result = helper.get_self_pickup_method(order_delivery_selected)
      expect(result).to be_nil
    end
  end

  describe '#get_delivery_method' do
    it 'returns delivery method from order' do
      result = helper.get_delivery_method(order_delivery_selected)
      expect(result.variety).to eq('delivery')
    end

    it 'returns nil if delivery is not used in order' do
      result = helper.get_delivery_method(order_pickup_selected)
      expect(result).to be_nil
    end
  end
end