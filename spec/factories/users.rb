FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :admin_email do |n|
    "test.admin#{n}@example.com"
  end

  factory :user do
    type ""
    name "Sample User"
    email { generate :email }
    cell_number { "183#{Faker::Number.number(8)}" }
    password 'example'
    password_confirmation 'example'
  end

  factory :customer do
    type "Customer"
    name "Sample Customer"
    email { generate :email }
    cell_number { "183#{Faker::Number.number(8)}" }
    password 'example'
    password_confirmation 'example'
  end

  factory :admin do
    type "Admin"
    name "Sample Admin"
    email { generate :admin_email }
    cell_number { "183#{Faker::Number.number(8)}" }
    password 'example'
    password_confirmation 'example'
  end
end
