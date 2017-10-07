class Transfer < ApplicationRecord
  # Relationships
  has_one    :transaction_log, class_name: 'Transaction', as: :transactable
  belongs_to :transferer,  class_name: 'User', foreign_key: 'transferer_id'
  belongs_to :transferee,  class_name: 'User', foreign_key: 'transferee_id'
  belongs_to :fund_source, class_name: 'Wallet',
                           foreign_key: 'fund_source_id',
                           optional: true
  belongs_to :fund_target, class_name: 'Wallet',
                           foreign_key: 'fund_target_id',
                           optional: true

  # Validations
  monetize :amount_cents, numericality: { greater_than: 0 }

  # Enums
  enum processor: { wallet: 0, alipay: 1 }
  enum status: { created: 0, pending: 1, failure: 2, success: 3 }
end
