class Geo < ApplicationRecord
  # Relationships
  has_many   :children,   class_name: 'Geo', foreign_key: 'parent_id'
  belongs_to :parent,     class_name: 'Geo', optional: true

  # Validations
  validates :id,   presence: true, uniqueness: true
  validates :name, presence: true

  # Scope
  scope :cn, -> { Geo.where(id: '86').first }
  scope :provinces_states, -> { Geo.where(level: :provinces_states) }
  scope :cities, -> { Geo.where(level: :city) }
  scope :districts, -> { Geo.where(level: :district) }
  scope :communities, -> { Geo.where(level: :community) }

  # Enum
  enum level: { country_region:   0,
                provinces_states: 1,
                city:             2,
                district:         3,
                community:        4 }
end
