require 'rails_helper'

RSpec.describe OrderService do

  let(:new_order) { FactoryGirl.create(:new_order) }
  let(:cart)  { FactoryGirl.create(:cart) }

  describe '#initialize' do
    it 'can create new order service with cart' do
      order_service = OrderService.new(cart_id: cart.id)
      expect(order_service.cart).to eq(cart)
      expect(order_service.order).to be_nil
    end

    it 'can create new order service with order' do
      order_service = OrderService.new(order_id: new_order.id)
      expect(order_service.order).to eq(new_order)
      expect(order_service.cart).to be_nil
    end
  end


end
