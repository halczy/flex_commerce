FactoryGirl.define do

  factory :category do
    name { Faker::Cat.name + Faker::Number.number(10).to_s }
    display_order 1
    flavor 0
    hide false
    parent_id nil
  end

  factory :brand, class: Category do
    name { Faker::Cat.name + Faker::Number.number(10).to_s }
    display_order 1
    flavor 1
    hide false
    parent_id nil
  end

  factory :feature, class: Category do
    name { Faker::Cat.name + Faker::Number.number(10).to_s }
    display_order 1
    flavor 2
    hide false
    parent_id nil
  end

end
