class Inventory < ApplicationRecord
  # Relationships
  belongs_to :user, optional: true
  belongs_to :product

  # Scope | Enum
  enum status: { unsold: 0 }


end
