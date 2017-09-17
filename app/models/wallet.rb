class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user

  # Validation
  monetize :balance_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :pending_cents, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_destroy :prevent_destroy

  def available_fund
    balance - pending
  end

  def sufficient_fund?(amount)
    available_fund >= amount
  end


  private

    def prevent_destroy
      errors[:base] << 'User wallet cannot be removed once created.'
      throw :abort
    end
end
