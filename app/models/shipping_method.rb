class ShippingMethod < ApplicationRecord
  # Relationships
  has_and_belongs_to_many :products
  has_many :shipping_rates, dependent: :destroy
  accepts_nested_attributes_for :shipping_rates, allow_destroy: true,
                                reject_if: proc { |att| att['name'].blank? }
  # Validations
  validates :variety, presence: true

  # Enum
  enum variety: { no_shipping: 0,
                  delivery: 1,
                  self_pickup: 2,
                  digital_delivery: 3 }
end
