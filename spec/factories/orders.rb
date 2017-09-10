FactoryGirl.define do
  factory :order do
    status 0
    association :user, factory: :customer
  end

  factory :new_order, class: Order do
    status 0
    association :user, factory: :customer

    after(:create) do |new_order|
      3.times do
        new_order.inventories << FactoryGirl.create(:inventory, status: 2,
                                                      user: new_order.user)
      end
    end
  end
end
