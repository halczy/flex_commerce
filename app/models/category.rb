class Category < ApplicationRecord
  # Relationships
  has_many :child_categories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category', optional: true

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :display_order, numericality: { greater_than_or_equal_to: 0 }

  # Scope / Enum
  scope :top_level, -> { where(parent: nil, hide: false) }
  scope :no_parent, -> { where(parent: nil) }
  enum flavor: { normal: 0, feature: 1 }

end
