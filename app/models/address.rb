class Address < ApplicationRecord
  # Relationships
  belongs_to :addressable, polymorphic: true, optional: true

end
