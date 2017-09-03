class Address < ApplicationRecord
  # Relationships
  belongs_to :addressable, polymorphic: true, optional: true

  # Validations
  validates :recipient, presence: true
  validates :contact_number, presence: true

end
