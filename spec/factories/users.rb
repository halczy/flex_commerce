FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  factory :user do
    type ""
    name "Sample User"
    email { generate :email }
    cell_number "18655551111"
    password 'example'
    password_confirmation 'example'
  end
end
