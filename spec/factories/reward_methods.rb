FactoryGirl.define do
  factory :ref_reward, class: RewardMethod do
    name 'Referral Reward'
    variety 0
    settings {{ percentage: 5 }}
    association :product, factory: :product
  end
end
