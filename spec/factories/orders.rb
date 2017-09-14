FactoryGirl.define do
  factory :order do
    status 0
    association :user, factory: :customer
  end

  factory :new_order, class: Order do
    status 0
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
    end
  end

  factory :order_pickup_selected, class: Order do
    status 0
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: pickup) }
    end
  end

  factory :order_delivery_selected, class: Order do
    status 0
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
    end
  end

  factory :order_mix_selected, class: Order do
    status 0
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
      order.inventories.first.update(shipping_method: pickup)
    end
  end

  factory :order_pickup_confirmed, class: Order do
    status 10
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: pickup) }
    end
  end

  factory :order_delivery_confirmed, class: Order do
    status 10
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
      FactoryGirl.create(:address, addressable: order)
    end
  end

  factory :order_mix_confirmed, class: Order do
    status 20
    association :user, factory: :customer

    after(:create) do |order|
      3.times do
        FactoryGirl.create(:inventory, status: 2, user: order.user, order: order)
      end
      delivery = FactoryGirl.create(:delivery)
      pickup = FactoryGirl.create(:self_pickup)
      order.inventories.each { |i| i.update(shipping_method: delivery) }
      order.inventories.first.update(shipping_method: pickup)
      FactoryGirl.create(:address, addressable: order)
    end
  end
end
