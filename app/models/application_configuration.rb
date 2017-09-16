class ApplicationConfiguration < ApplicationRecord
  # ATTR_ENCRYPTED
  attr_encrypted :value, key: ENV.fetch('APP_CONFIGURATION_SECRET')

  # Attributes
  attribute :value

  # Validations

end
