class Geo < ApplicationRecord
  # Relationships
  has_many   :children,   class_name: 'Geo', foreign_key: 'parent_id'
  belongs_to :parent,     class_name: 'Geo', optional: true

  # Validations
  validates :id,   presence: true, uniqueness: true
  validates :name, presence: true

  # Scope
  scope :cn, -> { Geo.country_region.first }

  # Enum
  enum level: { country_region:   0,
                province_state:   1,
                city:             2,
                district:         3,
                community:        4 }

  def self.default_scope
    order(id: :asc)
  end
end
