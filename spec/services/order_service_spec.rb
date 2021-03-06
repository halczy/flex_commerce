require 'rails_helper'

RSpec.describe OrderService do

  let(:cart)        { FactoryBot.create(:cart) }
  let(:customer)    { FactoryBot.create(:customer) }
  let(:delivery)    { FactoryBot.create(:delivery) }
  let(:self_pickup) { FactoryBot.create(:self_pickup) }
  let(:address)     { FactoryBot.create(:address) }

  let(:order)                   { FactoryBot.create(:order) }
  let(:order_selected)          { FactoryBot.create(:order, selected: true) }
  let(:order_set)               { FactoryBot.create(:order, set: true) }
  let(:order_confirmed)         { FactoryBot.create(:order, confirmed: true) }
  let(:order_pickup_selected)   { FactoryBot.create(:order, selected: true, only_pickup: true) }
  let(:order_pickup_set)        { FactoryBot.create(:order, set: true, only_pickup: true) }
  let(:order_delivery_selected) { FactoryBot.create(:order, selected: true, only_delivery: true) }
  let(:order_delivery_set)      { FactoryBot.create(:order, set:true, only_delivery: true) }
  let(:order_no_shipping_set)   { FactoryBot.create(:order, set: true, no_shipping: true) }
  let(:payment_order)           { FactoryBot.create(:payment_order) }
  let(:payment_success_order)   { FactoryBot.create(:payment_order, success: true) }
  let(:service_order)           { FactoryBot.create(:service_order) }
  let(:service_order_ppending)  { FactoryBot.create(:service_order, pickup_pending: true) }
  let(:service_order_shipped)   { FactoryBot.create(:service_order, shipped: true) }
  let(:completed_order)         { FactoryBot.create(:service_order, completed: true) }

  describe '#initialize' do
    it 'initializes new order service with cart instance' do
      order_service = OrderService.new(cart_id: cart.id)
      expect(order_service.cart).to eq(cart)
      expect(order_service.order).to be_nil
    end

    it 'initializes new order service with order instance' do
      order_service = OrderService.new(order_id: order.id)
      expect(order_service.order).to eq(order)
      expect(order_service.cart).to be_nil
    end
  end

  describe '#create' do
    before do
      @cart = FactoryBot.create(:cart, user: customer)
      3.times { FactoryBot.create(:inventory, cart: @cart) }
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
      empty_cart = FactoryBot.create(:cart, user: customer)
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
        order_service = OrderService.new(order_id: order.id)
        product = order.products.first
        order_service.send(:set_shipping_method, product, delivery)
        product.inventories.each do |inv|
          expect(inv.shipping_method).to eq(delivery)
        end
      end
    end

    it 'assigns shipping method to inventories' do
      order_service = OrderService.new(order_id: order.id)
      product_1, product_2, product_3 = order.products
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

  describe '#get_inventories' do
    it 'returns an array of self pickup inventories' do
      order_service = OrderService.new(order_id: order_selected.id)
      expect(order_service.get_products('self_pickup').count).to eq(1)
    end

    it 'returns an array of inventories marked for delivery' do
      order_service = OrderService.new(order_id: order_selected.id)
      expect(order_service.get_products('delivery').count).to eq(2)
    end

    it 'returns an empty array if shipping method is not set' do
      order_service = OrderService.new(order_id: order.id)
      expect(order_service.get_products('delivery')).to be_empty
    end

    it 'returns an array of inventories given the shipping method instance' do
      order_service = OrderService.new(order_id: order_delivery_selected)
      shipping_method = order_delivery_selected.shipping_methods.first
      expect(order_service.get_products(shipping_method).count).to eq(3)
    end
  end

  describe '#get_products' do
    context 'self pickup' do
      it 'returns an array of products marked for self pick-up' do
        order_service = OrderService.new(order_id: order_pickup_selected.id)
        expect(order_service.get_products('self_pickup')).
          to match_array(order_pickup_selected.products)
      end

      it 'returns an empty array if no products are marked for self pick-up' do
        order_service = OrderService.new(order_id: order_delivery_selected.id)
        expect(order_service.get_products('self_pickup')).to be_empty
      end

      it 'returns only products marked for self pick-up in a mix shipping method order' do
        order_service = OrderService.new(order_id: order_selected.id)
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
        order_service = OrderService.new(order_id: order_selected.id)
        expect(order_service.get_products('delivery').count).to eq(2)
      end
    end
  end

  describe 'set_address' do
    before do
      @order_service = OrderService.new(order_id: order_selected.id)
      @customer_address = FactoryBot.create(:address, addressable: customer)
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
      FactoryBot.create(:address, addressable: order_delivery_selected)
      order_service = OrderService.new(order_id: order_delivery_selected)
      expect(order_service.confirm_shipping).to be_truthy
      expect(order_service.order.status).to eq('shipping_confirmed')
    end

    it 'confirms shipping for mixed order' do
      FactoryBot.create(:address, addressable: order_selected)
      order_service = OrderService.new(order_id: order_selected)
      expect(order_service.confirm_shipping).to be_truthy
      expect(order_service.order.status).to eq('shipping_confirmed')
    end

    it 'does not confirm for delivery order if not address is set' do
      order_service = OrderService.new(order_id: order_delivery_selected)
      expect(order_service.confirm_shipping).to be_falsey
      expect(order_service.order.status).to eq('created')
    end

    it 'does not confirm for mixed order if not address is set' do
      order_service = OrderService.new(order_id: order_selected )
      expect(order_service.confirm_shipping).to be_falsey
      expect(order_service.order.status).to eq('created')
    end
  end

  describe 'shipping cost' do
    before do |example|
      if example.metadata[:require_mix]
        @mix_order = order_set
        @method_pickup = ShippingMethod.find_by(variety: 2)
        @method_delivery = ShippingMethod.find_by(variety: 1)
        rate = ShippingRate.find_by(geo_code: @mix_order.address.community)
        weight = @method_delivery.inventories.sum {|i| i.product.weight }
        add_on_weight = weight - 1 > 0 ? weight - 1 : 0
        @delivery_cost = rate.init_rate + add_on_weight * rate.add_on_rate
      end

      if example.metadata[:require_delivery]
        @delivery_order = order_delivery_set
        @method_delivery = ShippingMethod.find_by(variety: 1)
        rate = ShippingRate.find_by(geo_code: @delivery_order.address.community)
        weight = @method_delivery.inventories.sum {|i| i.product.weight }
        add_on_weight = weight - 1 > 0 ? weight - 1 : 0
        @delivery_cost = rate.init_rate + add_on_weight * rate.add_on_rate
      end

      if example.metadata[:require_pickup]
        @pickup_order = order_pickup_set
        @method_pickup = ShippingMethod.find_by(variety: 2)
        rate = @method_pickup.shipping_rates.first
        rate.update(init_rate_cents: 11111)
        @pickup_cost = Money.new(11111)
      end
    end

    describe '#compatible_shipping_rate' do
      it 'returns the lowest compatible shipping rate with order address' do
        test_rate = ShippingRate.new(geo_code: FactoryBot.create(:community).id,
                                     init_rate: 999.99, add_on_rate: 111.11)
        shipping_method = order_delivery_set.shipping_methods.first
        shipping_method.shipping_rates << test_rate
        order_delivery_set.address.update(community: test_rate.geo_code)

        order_service = OrderService.new(order_id: order_delivery_set)
        result = order_service.compatible_shipping_rate(shipping_method)
        expect(result).to eq(test_rate)
      end

      it 'returns false if there is no compatible shipping rate' do
        order_delivery_set.address.update(community: nil)
        shipping_method = order_delivery_set.shipping_methods.first
        order_service = OrderService.new(order_id: order_delivery_set)
        expect(order_service.compatible_shipping_rate(shipping_method)).to be_falsey
      end
    end

    describe '#billable_weight' do
      it 'returns sum of inventories weight under the given shipping method' do
        order_service = OrderService.new(order_id: order_delivery_set)
        products_weight = Product.all.sum { |p| p.weight }
        shipping_method = order_delivery_set.shipping_methods.first
        expect(order_service.billable_weight(shipping_method)).to eq(products_weight)
      end

      it 'returns billable weight for mixed order' do
        order_service = OrderService.new(order_id: order_set)
        products_weight = Product.all.sum { |p| p.weight }
        shipping_method = order_delivery_set.shipping_methods.last
        expect(order_service.billable_weight(shipping_method))
          .to be_between(0, products_weight)
      end
    end

    describe '#calculate_shipping' do
      describe '#delivery_cost' do
        it 'returns shipping cost', require_mix: true do
          order_service = OrderService.new(order_id: @mix_order)
          result = order_service.delivery_cost(@method_delivery)
          expect(result).to eq(@delivery_cost)
        end
      end

      describe '#pickup_cost' do
        it 'returns zero if method init_rate is zero', require_mix: true do
          order_service = OrderService.new(order_id: @mix_order)
          result = order_service.pickup_cost(@method_pickup)
          expect(result).to eq(0)
        end

        it 'returns method init_rate as shipping cost', require_mix: true do
          rate = @method_pickup.shipping_rates.sample
          rate.update(init_rate_cents: 12345)
          order_service = OrderService.new(order_id: @mix_order)
          result = order_service.pickup_cost(@method_pickup)
          expect(result).to eq(Money.new(12345))
        end
      end

      it 'calls delivery_cost', require_mix: true do
        order_service = OrderService.new(order_id: @mix_order)
        result = order_service.calculate_shipping(@method_delivery)
        expect(result).to eq(@delivery_cost)
      end

      it 'calls pickup_cost', require_mix: true do
        order_service = OrderService.new(order_id: @mix_order)
        result = order_service.calculate_shipping(@method_pickup)
        expect(result).to eq(0)
      end

      it 'returns zero if shipping method is no shipping' do
        order_service = OrderService.new(order_id: order_no_shipping_set)
        shipping_method = order_no_shipping_set.shipping_methods.first
        result = order_service.calculate_shipping(shipping_method)
        expect(result).to eq(0)
      end
    end

    describe '#total_inventories_cost' do
      it 'returns total inventories cost in order' do
        order_service = OrderService.new(order_id: order_set)
        order_service.confirm
        products_cost = Product.all.sum { |p| p.price_member}
        expect(order_service.total_inventories_cost).to eq(products_cost)
      end
    end

    describe '#total_shipping_cost' do
      it 'returns order shipping cost with mixed shipping method',
          require_mix: true do
        order_service = OrderService.new(order_id: @mix_order)
        expect(order_service.total_shipping_cost).to eq(@delivery_cost)
      end

      it 'returns order shipping cost for order with singular delivery method',
         require_delivery: true do
        order_service = OrderService.new(order_id: @delivery_order)
        expect(order_service.total_shipping_cost).to eq(@delivery_cost)
      end

      it 'returns order shipping cost for order with singular pickup method',
         require_pickup: true do
        order_service = OrderService.new(order_id: @pickup_order)
        expect(order_service.total_shipping_cost).to eq(@pickup_cost)
      end

      it 'returns order shipping cost for order with singular no shipping method' do
        order_service = OrderService.new(order_id: order_no_shipping_set)
        expect(order_service.total_shipping_cost).to eq(0)
      end
    end

    describe '#confirm_shipping_cost' do
      it 'saves shipping cost to order', require_mix: true do
        order_service = OrderService.new(order_id: @mix_order)
        order_service.send(:confirm_shipping_cost)
        expect(@mix_order.reload.shipping_cost).to eq(@delivery_cost)
      end
    end
  end

  describe '#confirm' do
    describe '#confirm_inventories' do
      it 'sets all inventories status to in checkout' do
        order_service = OrderService.new(order_id: order_delivery_set)
        order_service.send(:confirm_inventories)
        order_delivery_set.inventories.each do |inv|
          expect(inv.reload.status).to eq('in_checkout')
        end
      end

      it 'assigns product price to inventory' do
        order_service = OrderService.new(order_id: order_set)
        order_service.send(:confirm_inventories)
        order_set.inventories.each do |inv|
          expect(inv.reload.purchase_price).to eq(inv.product.price_member)
        end
      end

      it 'assigns product weight to inventory' do
        order_service = OrderService.new(order_id: order_set)
        order_service.send(:confirm_inventories)
        order_set.inventories.each do |inv|
          expect(inv.reload.purchase_weight).to eq(inv.product.weight)
        end
      end
    end

    it 'returns true and changes order status if confirmed' do
      order_service = OrderService.new(order_id: order_set)
      expect(order_service.confirm).to be_truthy
      expect(order_set.reload.status).to eq('confirmed')
    end

    it 'confirms order with no shipping method set' do
      order_service = OrderService.new(order_id: order_no_shipping_set)
      expect(order_service.confirm).to be_truthy
      expect(order_no_shipping_set.reload.status).to eq('confirmed')
    end

    it 'returns false and does not set shipping cost and status on failure' do
      order_service = OrderService.new(order_id: order.id)
      expect(order_service.confirm).to be_falsey
      expect(order.reload.status).to eq('created')
    end
  end

  describe '#staff_confirm' do
    it 'returns true if confirm is successfully' do
      order_service = OrderService.new(order_id: payment_success_order)
      expect(order_service.staff_confirm).to be_truthy
    end

    it 'returns false if confirm fails due to incorrect status' do
      order_service = OrderService.new(order_id: payment_order)
      expect(order_service.staff_confirm).to be_falsey
    end
  end

  describe '#set_pickup_ready' do
    it 'adds pickup_readied_at to shipment hash' do
      order_service = OrderService.new(order_id: service_order)
      order_service.set_pickup_ready
      expect(order_service.order.reload.shipment['pickup_readied_at']).to be_present
    end

    it 'sets order status to pickup pending' do
      order_service = OrderService.new(order_id: service_order)
      order_service.set_pickup_ready
      expect(order_service.order.reload.pickup_pending?).to be_truthy
    end

    it 'does not set status if order status is shipped' do
      service_order.shipped!
      order_service = OrderService.new(order_id: service_order)
      order_service.set_pickup_ready
      expect(order_service.order.reload.shipped?).to be_truthy
    end

    it 'does not set pickup ready of self pickup method is not in order' do
      inv = service_order.inventories.
              where(shipping_method: ShippingMethod.all.self_pickup.first)
      inv.update(shipping_method: nil)
      order_service = OrderService.new(order_id: service_order)
      expect(order_service.set_pickup_ready).to be_falsey
    end
  end

  describe '#add_tracking' do
    it 'adds tracking number and shipping company to shipment' do
      order_service = OrderService.new(order_id: service_order)
      params = { shipping_company: 'ABCD', tracking_number: '123456789'}
      order_service.add_tracking(params)
      expect(order_service.order.shipment['shipping_company']).to be_present
      expect(order_service.order.shipment['tracking_number']).to be_present
      expect(order_service.order.shipment['shipped_at']).to be_present
    end

    it 'sets order status to shipped' do
      order_service = OrderService.new(order_id: service_order)
      params = { shipping_company: 'ABCD', tracking_number: '123456789'}
      order_service.add_tracking(params)
      expect(order_service.order.shipped?).to be_truthy
    end
  end

  describe '#complete_pickup' do
    it 'sets pickup_completed_at to order shipment' do
      order_service = OrderService.new(order_id: service_order_ppending)
      order_service.complete_pickup
      expect(
        service_order_ppending.reload.shipment['pickup_completed_at']
      ).to be_present
    end

    it 'returns false when pickup_readied_at is nil' do
      order_service = OrderService.new(order_id: service_order)
      expect(order_service.complete_pickup).to be_falsey
    end
  end

  describe '#complete_shipping' do
    it 'sets shipping_completed_at to order shipment' do
      order_service = OrderService.new(order_id: service_order_shipped)
      order_service.complete_shipping
      expect(
        order_service.order.reload.shipment['shipping_completed_at']
      ).to be_present
    end

    it 'returns false when shipped_at is nil' do
      order_service = OrderService.new(order_id: service_order)
      expect(order_service.complete_shipping).to be_falsey
    end
  end

  describe '#complete' do
    it 'sets order to completed if all shipments are completed' do
      service_order_shipped.shipment[:pickup_completed_at] = Time.zone.now
      service_order_shipped.shipment[:shipping_completed_at] = Time.zone.now
      service_order_shipped.save
      order_service = OrderService.new(order_id: service_order_shipped)
      order_service.send(:complete)
      expect(order_service.order.reload.completed?).to be_truthy
    end

    it 'does not set order to completed if self pickup is not complted' do
      order_service = OrderService.new(order_id: service_order_shipped)
      order_service.complete_shipping
      expect(order_service.order.reload.completed?).to be_falsey
    end

    it 'does not set order to completed if shipping is not completed' do
      order_service = OrderService.new(order_id: service_order_ppending)
      order_service.complete_pickup
      expect(order_service.order.reload.completed?).to be_falsey
    end
  end
end
