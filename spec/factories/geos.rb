FactoryBot.define do
  factory :country, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.country + Faker::Number.number(2) }
    level 0
    parent nil
  end

  factory :china, class: Geo do
    id '86'
    name 'China'
    level 0
    parent nil
  end

  factory :province, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.state + Faker::Number.number(2) }
    level 1
    association :parent, factory: :country
  end

  factory :city, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.city + Faker::Number.number(2) }
    level 2
    association :parent, factory: :province
  end

  factory :district, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.community + Faker::Number.number(2) }
    level 3
    association :parent, factory: :city
  end

  factory :community, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.community + Faker::Number.number(2) }
    level 4
    association :parent, factory: :district
  end
end
