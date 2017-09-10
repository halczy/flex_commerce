require 'rails_helper'

RSpec.describe OrderService do

  let(:new_order) { FactoryGirl.create(:new_order) }
  let(:cart)      { FactoryGirl.create(:cart) }
  let(:customer)  { FactoryGirl.create(:customer) }

  describe '#initialize' do
    it 'initializes new order service with cart instance' do
      order_service = OrderService.new(cart_id: cart.id)
      expect(order_service.cart).to eq(cart)
      expect(order_service.order).to be_nil
    end

    it 'initializes new order service with order instance' do
      order_service = OrderService.new(order_id: new_order.id)
      expect(order_service.order).to eq(new_order)
      expect(order_service.cart).to be_nil
    end
  end

  describe '#create' do
    before do
      @cart = FactoryGirl.create(:cart, user: customer)
      3.times { FactoryGirl.create(:inventory, cart: @cart) }
    end

    describe '#build' do
      it 'creates a new order' do
        order_service = OrderService.new(cart_id: @cart)
        order_service.build
        expect(order_service.order).to be_an_instance_of(Order)
        expect(order_service.order.user).to eq(@cart.user)
      end
    end

    describe '#transfer_inventories' do
      it 'transfers inventories from cart to order' do
        order_service = OrderService.new(cart_id: @cart)
        order_service.build
        order_service.transfer_inventories
        expect(order_service.order.inventories.count).to eq(3)
        expect(@cart.inventories).to be_empty
        expect(order_service.order.inventories.sample.status).to eq('in_order')
      end
    end

    it 'creates new order with inventories from user cart' do
      order_service = OrderService.new(cart_id: @cart)
      expect(order_service.create).to be_an_instance_of Order
      expect(order_service.order.status).to eq('created')
      expect(order_service.order.inventories.count).to eq(3)
      expect(order_service.cart.reload.inventories).to be_empty
    end

    it 'does not create new order if cart is empty' do
      empty_cart = FactoryGirl.create(:cart, user: customer)
      order_service = OrderService.new(cart_id: empty_cart)
      expect(order_service.create).to be_falsey
      expect(Order.count).to eq(0)
      expect(order_service.order).to be_nil
    end

    it 'does not create new order for session cart' do
      order_service = OrderService.new(cart_id: cart.id)
      expect(order_service.create).to be_falsey
      expect(Order.count).to eq(0)
      expect(order_service.order).to be_nil
    end
  end

end
