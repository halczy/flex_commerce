class Category < ApplicationRecord
  # Relationships
  has_many :child_categories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category', optional: true

  # Validations
  validate  :ensure_parent_exists
  validates :name, presence: true, uniqueness: true
  validates :display_order, numericality: { greater_than_or_equal_to: 0 }

  # Scope / Enum
  scope :top_level, -> { where(parent: nil, hide: false) }
  scope :no_parent, -> { where(parent: nil) }
  enum flavor: { normal: 0, feature: 1 }

  def unassociate_children
    child_categories.each { |c| c.update(parent_id: nil) }
  end

  def move(magnitude)
    update(display_order: display_order + magnitude)
  end

  private

  def ensure_parent_exists
    return true if parent_id.nil?
    begin
      Category.find(self.parent_id)
    rescue ActiveRecord::RecordNotFound
      errors.add(:parent_id, 'category with this ID does not exist')
      false
    end
  end
end
