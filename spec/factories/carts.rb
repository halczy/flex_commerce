FactoryGirl.define do
  factory :cart do
    status 1
    association :user, factory: :customer
  end
end
