require 'rails_helper'

RSpec.describe OrdersHelper, type: :helper do

  let(:order_delivery_selected) { FactoryGirl.create(:order_delivery_selected) }


  describe '#subtotal_by' do
    before do
      @order_mix = FactoryGirl.create(:order_mix_set)
      order_service = OrderService.new(order_id: @order_mix)
      order_service.confirm
    end

    it 'reutrns to total purchase price of given product in order' do
      sample_product = @order_mix.products.sample
      result = helper.subtotal_by(@order_mix, sample_product)
      expect(result).to eq(sample_product.price_member)
    end
  end

  describe '#shipping_method_by' do
    it 'returns shipping method of the given product' do
      sample_product = order_delivery_selected.products.sample
      result = helper.shipping_method_by(order_delivery_selected, sample_product)
      expect(result).to eq('delivery')
    end
  end
end
