FactoryGirl.define do
  factory :address do
    name 'Factory'
    community { FactoryGirl.create(:community).id }
    district { Geo.find("#{community}").parent.id }
    city { Geo.find("#{district}").parent.id }
    province_state { Geo.find("#{city}").parent.id }
    country_region { Geo.find("#{province_state}").parent.id }
    street ""
    full_address ""
  end
end
