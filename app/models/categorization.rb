class Categorization < ApplicationRecord
  # Relationships
  belongs_to :product, touch: true
  belongs_to :category, touch: true

  # Validations
  validates_uniqueness_of :product_id, scope: :category_id
end
