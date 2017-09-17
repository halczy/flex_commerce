class Payment < ApplicationRecord
  # Relationships
  belongs_to :order, optional: true
end
