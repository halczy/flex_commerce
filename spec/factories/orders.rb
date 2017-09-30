FactoryGirl.define do
  factory :order do
    status 0
    association :user, factory: :customer

    transient do
      selected        false
      set             false
      confirmed       false
      only_pickup     false
      only_delivery   false
      no_shipping     false
    end

    after(:create) do |order, evaluator|
      # Add inventories to order
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end

      # Add shipping methods to order
      if evaluator.selected || evaluator.set || evaluator.confirmed
        delivery = FactoryGirl.create(:delivery)
        pickup = FactoryGirl.create(:self_pickup)
        no_shipping = FactoryGirl.create(:no_shipping)

        if evaluator.only_pickup
          order.inventories.each { |i| i.update(shipping_method: pickup) }
        elsif evaluator.only_delivery
          order.inventories.each { |i| i.update(shipping_method: delivery) }
        elsif evaluator.no_shipping
          order.inventories.each { |i| i.update(shipping_method: no_shipping) }
        else
          order.inventories.each { |i| i.update(shipping_method: delivery) }
          order.inventories.first.update(shipping_method: pickup)
        end
      end

      # Add delivery address with special matching shipping rate for testing
      if evaluator.set || evaluator.confirmed
        order.update(status: 10)

        unless evaluator.only_pickup
          address = FactoryGirl.create(:address, addressable: order)
          FactoryGirl.create(:shipping_rate, geo_code: address.community,
                                             init_rate: 999.99,
                                             add_on_rate: 111.11,
                                             shipping_method: delivery)
        end
      end

      # Add shipping cost to order and confirm inventories
      if evaluator.confirmed
        order.inventories.each do |inv|
          inv.update(status: 3, purchase_price: inv.product.price_member)
        end

        if evaluator.only_pickup || evaluator.no_shipping
          shipping_cost = Money.new(0)
        else
          shipping_cost = order.inventories.sum { |i| i.purchase_price }
        end

        order.update(status: 20, shipping_cost: shipping_cost)
      end
    end
  end

  factory :payment_order, class: Order do
    status 30
    association :user, factory: :customer

    transient do
      partial false
      fail    false
      success false
    end

    after(:create) do |order, evaluator|
      # Build order to confirm status
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
      order.inventories.first.update(shipping_method: pickup)
      address = FactoryGirl.create(:address, addressable: order)
      FactoryGirl.create(:shipping_rate, geo_code: address.community,
                                         init_rate: 999.99,
                                         add_on_rate: 111.11,
                                         shipping_method: delivery)
      order.inventories.each do |inv|
        inv.update(status: 3, purchase_price: inv.product.price_member,
                              purchase_weight: inv.product.weight)
      end
      shipping_cost = order.inventories.sum { |i| i.purchase_price }
      order.update(shipping_cost: shipping_cost)

      # Add a wallet payment for order
      order.user.wallet.update(balance: 999999)
      payment_service = PaymentService.new(order_id: order.id, processor: 'wallet',
                                           amount: Money.new(100))
      payment_service.create

      # Transient
      payment_service.charge if evaluator.partial
      order.update(status: 50) if evaluator.fail
      if evaluator.success
        payment_service.charge
        rps = PaymentService.new(order_id: order.id, processor: 'wallet')
        rps.create
        rps.charge
      end
    end
  end

  factory :service_order, class: Order do
    association :user, factory: :customer

    transient do
      pickup_pending false
      shipped        false
      completed      false
    end

    after(:create) do |order, evaluator|
      # Build order to confirm status
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
      order.inventories.first.update(shipping_method: pickup)
      address = FactoryGirl.create(:address, addressable: order)
      FactoryGirl.create(:shipping_rate, geo_code: address.community,
                                         init_rate: 999.99,
                                         add_on_rate: 111.11,
                                         shipping_method: delivery)
      order.inventories.each do |inv|
        inv.update(status: 3, purchase_price: inv.product.price_member,
                              purchase_weight: inv.product.weight)
      end
      shipping_cost = order.inventories.sum { |i| i.purchase_price }
      order.update(shipping_cost: shipping_cost)

      # Build successful payment
      order.user.wallet.update(balance: 999999)
      order.confirmed!
      payment_service = PaymentService.new(order_id: order.id, processor: 'wallet')
      payment_service.create
      payment_service.charge

      # Staff Confirm
      order.staff_confirmed!

      if evaluator.pickup_pending
        order.shipment[:pickup_readied_at] = DateTime.now
        order.save
        order.pickup_pending!
      end

      if evaluator.shipped
        order.shipment[:shipping_company] = 'FedEx'
        order.shipment[:tracking_number] = '654987321231'
        order.shipment[:shipped_at] = DateTime.now
        order.save
        order.shipped!
      end

      if evaluator.completed
        order.shipment[:shipping_company] = 'FedEx'
        order.shipment[:tracking_number] = '654987321231'
        order.shipment[:shipped_at] = DateTime.now
        order.shipment[:shipping_completed_at] = DateTime.now
        order.shipment[:pickup_readied_at] = DateTime.now
        order.shipment[:pickup_completed_at] = DateTime.now
        order.save
        order.completed!
      end
    end
  end
end
