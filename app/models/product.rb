class Product < ApplicationRecord
  # Realtionships
  has_many :categorizations
  has_many :categories, through: :categorizations
  has_many :images, as: :imageable

  # Validations
  validates :name, presence: true, length: { maximum: 30 }
  monetize :price_market_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_member_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_reward_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :cost_cents, numericality: { greater_than_or_equal_to: 0 }

end
