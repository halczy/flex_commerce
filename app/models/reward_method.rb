class RewardMethod < ApplicationRecord
  # Relationships
  belongs_to :product

  # Callbacks
  after_initialize :load_settings
  after_touch      :load_settings

  # Enum
  enum variety: { referral: 0 }

  # Attributes
  attribute :percentage

  # Validations
  validates_presence_of :name, :variety

  private

    def load_settings
      settings.each do |key, value|
        send("#{key}=", value)
      end
    end
end
