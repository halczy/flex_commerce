class Payment < ApplicationRecord
  # Relationships
  belongs_to :order, optional: true
  has_one    :transaction_log, class_name: 'Transaction', as: :originable

  # Validations
  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates_presence_of :processor, :variety, :status

  # Enum
  enum processor: { wallet: 0, alipay: 1 }
  enum variety:   { charge: 0, refund: 1, reward: 2 }
  enum status:    {
    created: 0,
    insufficient_fund: 10, expired: 11,
    client_side_confirmed: 20, processor_confirmed: 21, confirmed: 22
  }

end
