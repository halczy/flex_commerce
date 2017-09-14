require 'rails_helper'

RSpec.describe OrderService do

  let(:cart)        { FactoryGirl.create(:cart) }
  let(:customer)    { FactoryGirl.create(:customer) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }
  let(:address)     { FactoryGirl.create(:address) }

  let(:new_order) { FactoryGirl.create(:new_order) }
  let(:order_pickup_selected) { FactoryGirl.create(:order_pickup_selected) }
  let(:order_delivery_selected) { FactoryGirl.create(:order_delivery_selected) }
  let(:order_mix_selected) { FactoryGirl.create(:order_mix_selected) }
  let(:order_pickup_confirmed) { FactoryGirl.create(:order_pickup_confirmed) }
  let(:order_delivery_confirmed) { FactoryGirl.create(:order_delivery_confirmed) }
  let(:order_mix_confirmed) { FactoryGirl.create(:order_mix_confirmed) }

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

  describe '#set_shipping' do
    context 'set_shipping_method' do
      it 'sets shipping method for inventories under product' do
        order_service = OrderService.new(order_id: new_order.id)
        product = new_order.products.first
        order_service.send(:set_shipping_method, product, delivery)
        product.inventories.each do |inv|
          expect(inv.shipping_method).to eq(delivery)
        end
      end
    end

    it 'assigns shipping method to inventories' do
      order_service = OrderService.new(order_id: new_order.id)
      product_1, product_2, product_3 = new_order.products
      params = {
                 '0' => { "shipping_methods" => delivery.id, "id" => product_1.id },
                 '1' => { "shipping_methods" => delivery.id, "id" => product_2.id },
                 '2' => { "shipping_methods" => self_pickup, "id" => product_3.id }
               }
      order_service.set_shipping(params)
      expect(product_1.inventories.sample.shipping_method).to eq(delivery)
      expect(product_2.inventories.sample.shipping_method).to eq(delivery)
      expect(product_3.inventories.sample.shipping_method).to eq(self_pickup)
    end
  end

  describe '#get_products' do
    context 'self pickup' do
      it 'returns an araay of products marked for self pick-up' do
        order_service = OrderService.new(order_id: order_pickup_selected.id)
        expect(order_service.get_products('self_pickup')).
          to match_array(order_pickup_selected.products)
      end

      it 'returns an empty array if no products are marked for self pick-up' do
        order_service = OrderService.new(order_id: order_delivery_selected.id)
        expect(order_service.get_products('self_pickup')).to be_empty
      end

      it 'returns only products marked for self pick-up in a mix shipping method order' do
        order_service = OrderService.new(order_id: order_mix_selected.id)
        expect(order_service.get_products('self_pickup').count).to eq(1)
      end
    end

    context 'delivery' do
      it 'returns an array of products marked for delivery' do
        order_service = OrderService.new(order_id: order_delivery_selected.id)
        expect(order_service.get_products('delivery')).
          to match_array(order_delivery_selected.products)
      end

      it 'returns an empty array if no products are marked for delivery' do
        order_service = OrderService.new(order_id: order_pickup_selected.id)
        expect(order_service.get_products('delivery')).
          to be_empty
      end

      it 'returns only products marked for delivery in a mix shipping methods' do
        order_service = OrderService.new(order_id: order_mix_selected.id)
        expect(order_service.get_products('delivery').count).to eq(2)
      end
    end
  end

  describe 'set_address' do
    before do
      @order_service = OrderService.new(order_id: order_mix_selected.id)
      @customer_address = FactoryGirl.create(:address, addressable: customer)
    end

    it 'duplicates customer address to mixed order' do
      @order_service.set_address(@customer_address.id)
      expect(@order_service.order.address.addressable).to eq(@order_service.order)
      expect(@customer_address.reload.addressable).to eq(customer)
    end
  end

  describe 'confirm_shipping' do
    it 'confirms shipping for self-pickup order' do
      order_service = OrderService.new(order_id: order_pickup_selected)
      expect(order_service.confirm_shipping).to be_truthy
      expect(order_service.order.status).to eq('shipping_confirmed')
    end

    it 'confirms shipping for delivery order' do
      FactoryGirl.create(:address, addressable: order_delivery_selected)
      order_service = OrderService.new(order_id: order_delivery_selected)
      expect(order_service.confirm_shipping).to be_truthy
      expect(order_service.order.status).to eq('shipping_confirmed')
    end

    it 'confirms shipping for mixed order' do
      FactoryGirl.create(:address, addressable: order_mix_selected)
      order_service = OrderService.new(order_id: order_mix_selected)
      expect(order_service.confirm_shipping).to be_truthy
      expect(order_service.order.status).to eq('shipping_confirmed')
    end

    it 'does not confirm for delivery order if not address is set' do
      order_service = OrderService.new(order_id: order_delivery_selected)
      expect(order_service.confirm_shipping).to be_falsey
      expect(order_service.order.status).to eq('created')
    end

    it 'does not confirm for mixed order if not address is set' do
      order_service = OrderService.new(order_id: order_mix_selected )
      expect(order_service.confirm_shipping).to be_falsey
      expect(order_service.order.status).to eq('created')
    end
  end

  describe 'shipping cost' do
    describe '#billable_weight' do
      it 'returns sum of inventories weight that are billable' do
        order_service = OrderService.new(order_id: order_delivery_confirmed)
        products_weight = Product.all.sum { |p| p.weight }
        expect(order_service.billable_weight).to eq(products_weight)
      end

      it 'returns no billable weight for pick up exclusive order' do
        order_service = OrderService.new(order_id: order_pickup_confirmed)
        expect(order_service.billable_weight).to eq(0)
      end

      it 'returns billable weight for mixed order' do
        order_service = OrderService.new(order_id: order_mix_confirmed)
        products_weight = Product.all.sum { |p| p.weight }
        expect(order_service.billable_weight).to be_between(0, products_weight)
      end
    end

  end

end
