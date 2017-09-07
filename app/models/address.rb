class Address < ApplicationRecord
  # Relationships
  belongs_to :addressable, polymorphic: true, optional: true

  # Validations
  validates_presence_of :recipient, :contact_number, :province_state, :street

  def build_full_address
    addr = ""
    addr << Geo.find(province_state).name if province_state.present?
    addr << Geo.find(city).name if city.present?
    addr << Geo.find(district).name if district.present?
    addr << Geo.find(community).name if community.present?
    addr << street
    tap { |address| update(full_address: addr) }
  end

  def destroyable?
    return false if addressable_type == 'Order'  # TODO: REFACTOR ONCE ORDER MODEL IS AVAILABLE
    return true if addressable.instance_of?(Customer) || addressable.nil?
  end
end
