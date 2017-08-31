FactoryGirl.define do
  factory :country, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.country }
    level 0
    parent nil
  end

  factory :province, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.state }
    level 1
    association :parent, factory: :country
  end

  factory :city, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.city }
    level 2
    association :parent, factory: :province
  end

  factory :district, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.community }
    level 3
    association :parent, factory: :city
  end

  factory :community, class: Geo do
    id { Faker::Number.number }
    name { Faker::Address.community }
    level 4
    association :parent, factory: :district
  end
end
