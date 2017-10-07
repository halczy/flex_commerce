class Referral < ApplicationRecord
  # Relationships
  belongs_to :referer, class_name: 'User', foreign_key: 'referer_id'
  belongs_to :referee, class_name: 'User', foreign_key: 'referee_id'

  # Validations
  validates :referer, presence: true
  validates :referee, presence: true, uniqueness: true
  validates_with ReferralValidator
end
