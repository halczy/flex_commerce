FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    tag_line { Faker::Coffee.origin }
    sku { Faker::Number.unique.number(10) }
    introduction { Faker::Coffee.notes }
    description { Faker::Lorem.paragraph }
    specification { Faker::Lorem.paragraph }
    price_market { Faker::Number.decimal(4, 2).to_f }
    price_member { Faker::Number.decimal(3, 2).to_f }
    price_reward { Faker::Number.decimal(2, 2).to_f }
    cost { Faker::Number.decimal(1, 2).to_f }
  end
end
