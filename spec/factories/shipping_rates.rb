FactoryGirl.define do
  factory :shipping_rate do
    geo_code "*"
    init_rate 0
    add_on_rate 0
    association :shipping_method, factory: :self_pickup
  end

  factory :shipping_rate_province, class: ShippingRate do
    geo_code { FactoryGirl.create(:province).id }
    init_rate { Faker::Number.decimal(2) }
    add_on_rate { Faker::Number.decimal(2) }
    association :shipping_method, factory: :delivery
  end
end
