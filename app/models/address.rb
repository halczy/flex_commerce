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
    return false if addressable.instance_of?(Order)
    return true  if addressable.instance_of?(Customer) || addressable.nil?
  end

  def compact_select
    select_html = ""
    select_html << "<strong class='ml-1'>#{recipient}</strong>"
    select_html << " (#{name}) " if name.present?
    select_html << " | #{full_address} "
    select_html << " | #{contact_number} "
    select_html.html_safe
  end

  def copy_to(object)
    object_address = self.dup
    object_address.addressable = object
    object_address.save
  end

  def geo_codes
    Array.new.tap do |codes|
      attributes.each_value { |value| codes << value if Geo.find_by(id: value) }
      codes.reverse!
    end
  end
end
