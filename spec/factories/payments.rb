FactoryGirl.define do
  factory :payment do
    association :order, factory: :order, confirmed: true
    amount { order.total }
    status 0
    processor 0
    variety 0
    processor_response nil
  end
end
