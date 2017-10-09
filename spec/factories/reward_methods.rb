FactoryGirl.define do
  factory :ref_reward, class: RewardMethod do
    name 'Referral Reward'
    variety 0
    settings {{ percentage: 5 }}

    after(:create) do |reward|
      3.times { reward.products << FactoryGirl.create(:product) }
    end
  end
end
