class ApplicationConfiguration < ApplicationRecord
  # Encryption
  attr_encrypted :value, key: ENV.fetch('APP_CONFIGURATION_SECRET')

  # Attributes
  attribute :value

  # Callbacks
  before_save :downcase_name

  # Validations
  validates :name, presence: true, uniqueness: true


  private

    def downcase_name
      name.downcase!
    end
end
