require 'rails_helper'

RSpec.describe OrdersHelper, type: :helper do

  let(:order_delivery_selected) { FactoryGirl.create(:order, selected: true,
                                                             only_delivery: true) }
  let(:order_pickup_selected)   { FactoryGirl.create(:order, selected: true,
                                                             only_pickup: true) }
  let(:order_confirmed)         { FactoryGirl.create(:order, confirmed: true) }
  let(:service_order)           { FactoryGirl.create(:service_order) }

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
        sample_product = order_confirmed.products.sample
        result = helper.subtotal_by(order_confirmed, sample_product)
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

  describe 'tab?' do
    describe '#completed_tab?' do
      it 'returns active when no filter is provided' do
        expect(helper.completed_tab?({})).to eq('active')
      end

      it 'returns active when service_process filter is provided' do
        expect(helper.completed_tab?({filter: 'service_process'})).to eq('active')
      end
    end

    describe '#pending_tab?' do
      it 'returns nil when no filter is provided' do
        expect(helper.pending_tab?({})).to be_nil
      end

      it 'returns active when payment_process filter is provided' do
        expect(helper.pending_tab?({filter: 'payment_process'})).to eq('active')
      end
    end

    describe '#incomplete_tab?' do
      it 'returns nil when no filter is provided' do
        expect(helper.incomplete_tab?({})).to be_nil
      end

      it 'returns active when creation_process fitler is provided' do
        expect(helper.incomplete_tab?({filter: 'creation_process'})).to eq('active')
      end
    end
  end

  describe '#display_mark_as_pickup_completed?' do
    it 'returns true if self pickup shipping method is present' do
      expect(display_mark_as_pickup_ready?(service_order)).to be_truthy
    end

    it 'returns false if order have not been confirmed by staff' do
      expect(display_mark_as_pickup_ready?(order_confirmed)).to be_falsey
    end

    it 'returns false if order shipment pickup_readied_at exists' do
      service_order.update(shipment: { pickup_readied_at: Time.now })
      expect(display_mark_as_pickup_ready?(service_order)).to be_falsey
    end
  end

  describe '#display_mark_as_pickup_completed' do
    it 'returns true if shipment include pickup_readied_at' do
      service_order.update(shipment: { pickup_readied_at: Time.now })
      expect(display_mark_as_pickup_completed?(service_order)).to be_truthy
    end

    it 'returns false if shipment include pickup_completed_at' do
      service_order.update(shipment: { pickup_readied_at: Time.now })
      service_order.update(shipment: { pickup_completed_at: Time.now })
      expect(display_mark_as_pickup_completed?(service_order)).to be_falsey
    end

    it 'returns false if order shipment is not initialized' do
      expect(display_mark_as_pickup_completed?(service_order)).to be_falsey
    end
  end
end
