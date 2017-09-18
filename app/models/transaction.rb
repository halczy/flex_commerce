class Transaction < ApplicationRecord
  # Relationships
  belongs_to :transactable, polymorphic: true, required: true
  belongs_to :origin,       polymorphic: true, required: true

  # Validation
  monetize  :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates_presence_of :amount_cents, :variety, :status


end
