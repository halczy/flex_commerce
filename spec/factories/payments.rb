FactoryGirl.define do
  factory :payment do
    amount "MyString"
    status 1
    processor 1
    variety 1
    processor_response ""
    order nil
  end
end
