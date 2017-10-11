class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user
  has_many   :transactions_logs, as: :processable
  has_many   :transfer_ins,  class_name: 'Transfer', foreign_key: 'fund_target_id'
  has_many   :transfer_outs, class_name: 'Transfer', foreign_key: 'fund_source_id'

  # Validation
  monetize :balance_cents,      numericality: { greater_than_or_equal_to: 0 }
  monetize :pending_cents,      numericality: { greater_than_or_equal_to: 0 }
  monetize :withdrawable_cents, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_destroy :prevent_destroy

  def available_fund
    balance - pending
  end

  def withdrawable_fund
    balance - pending
  end

  def sufficient_fund?(amount)
    available_fund >= amount
  end

  def credit(amount)
    return false if amount <= 0
    self.balance += amount
    self.withdrawable += amount
    save
  end

  def conditional_credit(amount)
    return false if amount <= 0
    self.balance += amount
    save
  end

  def debit(amount)
    return false if amount < 0 || !sufficient_fund?(amount)
    self.balance -= amount
    save
    sync_withdrawable
  end

  def create_withdraw(amount)
    return false if amount < 0 || amount > withdrawable_fund
    self.withdrawable -= amount
    self.balance -= amount
    self.pending += amount
    save
  end

  def withdraw(amount)
    return false if amount > pending
    self.pending -= amount
    save
  end

  private

    def prevent_destroy
      errors[:base] << 'User wallet cannot be removed once created.'
      throw :abort
    end

    def sync_withdrawable
      update(withdrawable: balance) if balance < withdrawable
    end
end
