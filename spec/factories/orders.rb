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
        FactoryGirl.create(:inventory, status: 2, user: new_order.user,
                                                  order: new_order)
      end
      FactoryGirl.create(:address, addressable: new_order).build_full_address
    end
  end

end
