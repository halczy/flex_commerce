class ShippingMethod < ApplicationRecord
  # Relationships
  has_and_belongs_to_many :products
  has_many :shipping_rates, dependent: :destroy
  has_many :inventories
  has_one  :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :shipping_rates, allow_destroy: true
  accepts_nested_attributes_for :address, allow_destroy: true

  # Validations
  validates :name,    presence: true
  validates :variety, presence: true

  #
  attribute :addresses

  # Enum
  enum variety: { no_shipping: 0,
                  delivery: 1,
                  self_pickup: 2 }

  # def address
  #   addresses.first
  # end

  private

    def reject_shipping_rates(attributes)
      geo = Geo.find_by(id: attributes['geo_code'])
      attributes['geo_code'].blank? || geo.nil?
    end
end
