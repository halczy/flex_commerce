class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user

  # Validation
  monetize :balance_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :pending_cents, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_destroy :prevent_destroy


  private

    def prevent_destroy
      errors[:base] << 'User wallet cannot be removed once created.'
      throw :abort
    end
end
