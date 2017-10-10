FactoryGirl.define do
  factory :ref_reward, class: RewardMethod do
    name 'Referral Reward'
    variety 0
    settings {{ percentage: 5 }}

    transient do
      no_products false
    end

    after(:create) do |reward, evaluator|
      unless evaluator.no_products
        3.times { reward.products << FactoryGirl.create(:product) }
      end
    end
  end
end
