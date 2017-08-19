FactoryGirl.define do
  factory :inventory do
    status 0
    purchased_at ""
    returned_at ""
    association :product, factory: :product
  end
end
