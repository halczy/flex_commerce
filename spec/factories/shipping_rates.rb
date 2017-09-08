FactoryGirl.define do
  factory :shipping_rate do
    geo_code "*"
    init_rate 0
    add_on_rate 0
    association :shipping_method, factory: :shipping_method
  end
end
