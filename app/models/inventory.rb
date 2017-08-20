class Inventory < ApplicationRecord
  # Relationships
  belongs_to :user, optional: true
  belongs_to :product

  # Scope | Enum
  scope :available, -> { where(status: 0) }
  enum status: { unsold: 0, in_cart: 1, in_order: 2, in_checkout: 3,
                 sold: 4, returned: 5 }

end
