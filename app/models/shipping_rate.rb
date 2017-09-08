class ShippingRate < ApplicationRecord
  # Relationships
  belongs_to :shipping_method

  # Validations
  validates :geo_code, presence: true
  monetize :init_rate_cents,   numericality: { greater_than_or_equal_to: 0 }
  monetize :add_on_rate_cents, numericality: { greater_than_or_equal_to: 0 }

end
