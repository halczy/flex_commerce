class ShippingMethod < ApplicationRecord
  # Relationships
  has_and_belongs_to_many :products

  # Validations
  validates :variety, presence: true

  # Enum
  enum variety: { no_shipping: 0,
                  delivery: 1,
                  self_pickup: 2,
                  digital_delivery: 3 }
end
