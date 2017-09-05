class Address < ApplicationRecord
  # Relationships
  belongs_to :addressable, polymorphic: true, optional: true

  # Validations
  validates_presence_of :recipient, :contact_number, :street

end
