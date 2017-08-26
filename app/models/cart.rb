class Cart < ApplicationRecord
  # Relationships
  belongs_to :user, optional: true

  # Scope / Enum
  enum { inactive: 0, active: 1, limited_inventory_removed: 2 }

end
