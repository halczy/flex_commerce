class ApplicationConfiguration < ApplicationRecord
  # Encryption
  attr_encrypted :value, key: ENV.fetch('APP_CONFIGURATION_SECRET')

  # Attributes
  attribute :value

  # Callbacks
  before_save :downcase_name

  # Validations
  validates :name, presence: true, uniqueness: true

  def self.get(name)
    config = ApplicationConfiguration.find_by(name: name)
    config.try(:value) || config.try(:plain) || config.try(:status)
  end

  private

    def downcase_name
      name.downcase!
    end
end
