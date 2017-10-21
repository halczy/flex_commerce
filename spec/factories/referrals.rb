FactoryBot.define do
  factory :referral do
    association :referer, factory: :customer
    association :referee, factory: :customer
  end
end
