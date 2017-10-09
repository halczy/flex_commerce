class RewardMethod < ApplicationRecord
  # Relationships
  belongs_to :product

  # Enum
  enum variety: { referral: 0 }

  # Attributes
end
