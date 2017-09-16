class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user

  # Validation
  monetize :balance_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :pending_cents, numericality: { greater_than_or_equal_to: 0 }


end
