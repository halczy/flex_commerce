class RewardMethod < ApplicationRecord
  # Relationships
  has_and_belongs_to_many :products

  # Callbacks
  after_initialize :load_settings
  after_touch      :load_settings

  # Enum
  enum variety: { referral: 0, cash_back: 1 }

  # Attributes
  attribute :percentage

  # Validations
  validates_presence_of :name, :variety

  def destroyable?
    products.empty?
  end

  private

    def load_settings
      settings.each do |key, value|
        send("#{key}=", value)
      end
    end
end
