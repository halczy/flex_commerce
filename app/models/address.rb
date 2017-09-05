class Address < ApplicationRecord
  # Relationships
  belongs_to :addressable, polymorphic: true, optional: true

  # Validations
  validates_presence_of :recipient, :contact_number, :province_state, :street

  def build_full_address
    addr = ""
    addr << Geo.find(province_state).name unless province_state.empty?
    addr << Geo.find(city).name unless city.empty?
    addr << Geo.find(district).name unless district.empty?
    addr << Geo.find(community).name unless community.empty?
    addr << street
    tap { |address| update(full_address: addr) }
  end
end
