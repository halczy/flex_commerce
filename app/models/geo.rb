class Geo < ApplicationRecord
  # Relationships
  has_many   :child_geos, class_name: 'Geo', foreign_key: 'parent_id'
  belongs_to :parent,     class_name: 'Geo', optional: true

  # Validations
  validates :id,   presence: true, uniqueness: true
  validates :name, presence: true

  # Scope

end
