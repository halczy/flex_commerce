FactoryBot.define do
  factory :address do
    name 'Factory'
    recipient { Faker::Name.name }
    contact_number { "183#{Faker::Number.number(8)}" }
    community { FactoryBot.create(:community).id }
    district { Geo.find("#{community}").parent.id }
    city { Geo.find("#{district}").parent.id }
    province_state { Geo.find("#{city}").parent.id }
    country_region { Geo.find("#{province_state}").parent.id }
    street '123 Jump Street, Apt. 321'
    full_address ""
  end
end
