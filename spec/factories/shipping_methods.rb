FactoryGirl.define do
  factory :no_shipping, class: ShippingMethod do
    name 'No Shipping'
    variety 0
  end

  factory :delivery, class: ShippingMethod do
    name 'Delivery'
    variety 1

    after(:create) do |delivery|
      3.times do
        FactoryGirl.create(:shipping_rate_province, shipping_method: delivery)
      end
    end
  end

  factory :delivery_sa, class: ShippingMethod do
    name 'Delivery'
    variety 1
  end

  factory :self_pickup, class: ShippingMethod do
    name 'Self Pickup'
    variety 2

    after(:create) do |self_pickup|
      FactoryGirl.create(:shipping_rate, shipping_method: self_pickup)
      FactoryGirl.create(:address, addressable: self_pickup).build_full_address
    end
  end

  factory :self_pickup_sa, class: ShippingMethod do
    name 'Self Pickup'
    variety 2
  end

end
