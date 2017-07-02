FactoryGirl.define do
  factory :category do
    name { Faker::Cat.name }
    display_order 1
    level 1
    hide false
  end
end
