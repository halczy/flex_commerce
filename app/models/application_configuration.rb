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
    if config
      return config.value  if     config.value.present?
      return config.plain  if     config.plain.present?
      return config.status unless config.status.nil?
    end
  end

  private

    def downcase_name
      name.downcase!
    end
end
