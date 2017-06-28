FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :cell_number do |n|
    "183#{n}#{Faker::Number.number(7)}"
  end

  factory :user do
    type ""
    name "Sample User"
    email { generate :email }
    cell_number { generate :cell_number }
    password 'example'
    password_confirmation 'example'
  end
end
