FactoryGirl.define do
  factory :no_shipping, class: ShippingMethod do
    name 'No Shipping'
    variety 0
  end

  factory :delivery, class: ShippingMethod do
    name 'Delivery'
    variety 1
  end

  factory :self_pickup, class: ShippingMethod do
    name 'Self Pickup'
    variety 2
  end

end
