class Product < ApplicationRecord
  # Realtionships

  # Validations
  validates :name, presence: true, length: { maximum: 30 }
  monetize :price_market_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_member_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_reward_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :cost_cents, numericality: { greater_than_or_equal_to: 0 }

end
