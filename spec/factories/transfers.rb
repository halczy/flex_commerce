FactoryGirl.define do
  factory :transfer do
    amount { Money.new(100) }
    processor 'wallet'
    transferer { FactoryGirl.create(:customer) }
    transferee { FactoryGirl.create(:customer) }
  end
end
