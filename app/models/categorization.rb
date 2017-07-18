class Categorization < ApplicationRecord
  # Relationships
  belongs_to :product
  belongs_to :category

  # Validations
  validates_uniqueness_of :product_id, scope: :category_id
end
