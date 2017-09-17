FactoryGirl.define do
  factory :order do
    status 0
    association :user, factory: :customer

    transient do
      selected      false
      set           false
      confirmed     false
      only_pickup   false
      only_delivery false
      no_shipping   false
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

  # factory :order_no_shipping, class: Order do
  #   status 10
  #   association :user, factory: :customer

  #   transient do
  #     set           false
  #     confirmed     false
  #   end

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     no_shipping = FactoryGirl.create(:no_shipping)

  #     if evaluator.set || evaluator.confirmed
  #       order.inventories.each { |i| i.update(shipping_method: no_shipping) }
  #     end

  #     if evaluator.confirmed

  #     end
  #   end
  # end

  # factory :order_pickup_selected, class: Order do
  #   status 0
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     pickup = FactoryGirl.create(:self_pickup)
  #     order.inventories.each { |i| i.update(shipping_method: pickup) }
  #   end
  # end

  # factory :order_delivery_selected, class: Order do
  #   status 0
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     delivery = FactoryGirl.create(:delivery)
  #     order.inventories.each { |i| i.update(shipping_method: delivery) }
  #   end
  # end

  # factory :order_mix_selected, class: Order do
  #   status 0
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     delivery = FactoryGirl.create(:delivery)
  #     pickup = FactoryGirl.create(:self_pickup)
  #     order.inventories.each { |i| i.update(shipping_method: delivery) }
  #     order.inventories.first.update(shipping_method: pickup)
  #   end
  # end

  # factory :order_pickup_set, class: Order do
  #   status 10
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     pickup = FactoryGirl.create(:self_pickup)
  #     order.inventories.each { |i| i.update(shipping_method: pickup) }
  #   end
  # end

  # factory :order_delivery_set, class: Order do
  #   status 10
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     delivery = FactoryGirl.create(:delivery)
  #     order.inventories.each { |i| i.update(shipping_method: delivery) }
  #     address = FactoryGirl.create(:address, addressable: order)
  #     FactoryGirl.create(:shipping_rate, geo_code: address.community,
  #                                        init_rate: 999.99,
  #                                        add_on_rate: 111.11,
  #                                        shipping_method: delivery)
  #   end
  # end

  # factory :order_mix_set, class: Order do
  #   status 10
  #   association :user, factory: :customer

  #   after(:create) do |order|
  #     3.times do
  #       FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
  #     end
  #     delivery = FactoryGirl.create(:delivery)
  #     pickup = FactoryGirl.create(:self_pickup)
  #     order.inventories.each { |i| i.update(shipping_method: delivery) }
  #     order.inventories.first.update(shipping_method: pickup)
  #     address = FactoryGirl.create(:address, addressable: order)
  #     FactoryGirl.create(:shipping_rate, geo_code: address.community,
  #                                        init_rate: 999.99,
  #                                        add_on_rate: 111.11,
  #                                        shipping_method: delivery)
  #   end
  # end

end
