class Payment < ApplicationRecord
  # Relationships
  belongs_to :order, optional: true

  # Validations
  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates_presence_of :processor, :variety, :status

  # Enum
  enum processor: { wallet: 0, alipay: 1 }
  enum variety:   { charge: 0, refund: 1, transfer: 2 }
  enum status:    { created: 0, client_site_confirmed: 1, processor_confirmed: 2 }

end
