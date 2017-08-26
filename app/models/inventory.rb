class Inventory < ApplicationRecord
  # Relationships
  belongs_to :user, touch: true, optional: true
  belongs_to :product, touch: true

  # Scope | Enum
  scope :available,     -> { where(status: 0) }
  scope :unavailable,   -> { where.not(status: 0) }
  scope :destroyable,   -> { where("status <= ?", 2) }
  scope :undestroyable, -> { where("status >= ?", 3) }
  enum status: { unsold: 0, in_cart: 1, in_order: 2, in_checkout: 3,
                 sold: 4, returned: 5 }

end
