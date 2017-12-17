class Category < ApplicationRecord
  include TranslateEnum

  # Relationships
  belongs_to :parent,           class_name: 'Category', optional: true, touch: true
  has_many   :child_categories, class_name: 'Category', foreign_key: 'parent_id'
  has_many   :categorizations,  dependent: :destroy
  has_many   :products,         through: :categorizations

  # Validations
  validate  :ensure_parent_exists
  validates :name, presence: true, uniqueness: true
  validates :display_order, numericality: { greater_than_or_equal_to: 0 }

  # Scope
  scope :special,   -> { where("flavor >= ?", 2) }
  scope :top_level, -> { where(parent: nil, hide: false, flavor: 0) }
  scope :no_parent, -> { where(parent: nil, flavor: 0) }
  scope :children,  -> { where(flavor: 0).where.not(parent: nil) }

  # Enum
  enum flavor: { regular: 0, brand: 1, feature: 2 }
  translate_enum :flavor

  def unassociate_children
    child_categories.each { |c| c.update(parent_id: nil) }
  end

  def move(magnitude)
    update(display_order: display_order + magnitude)
  end

  def refine
    refined_categories = []
    return refined_categories if products.empty?
    products.each do |product|
      refined_categories << product.categories.select do |category|
        regular? ? category.brand? : category.regular?
      end
    end
    refined_categories.flatten.uniq
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
