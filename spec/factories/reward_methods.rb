FactoryGirl.define do
  factory :ref_reward do
    name 'Referral Reward'
    variety 0
    settings { percentage: 5 }
  end
end
