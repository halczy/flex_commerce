class Product < ApplicationRecord
  # Realtionships
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :images, as: :imageable, dependent: :destroy
  has_many :inventories, dependent: :destroy

  # Nested form
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :reject_images

  # Validations
  validates :name, presence: true, length: { maximum: 30 }
  monetize :price_market_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_member_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_reward_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :cost_cents, numericality: { greater_than_or_equal_to: 0 }

  def associate_images
    return if extract_images.empty?
    image_files = extract_images
    image_files.each do |image_file|
      Image.associate(self, image_file, 1)
    end
  end

  def unassociate_images
    images.each { |img| img.untag }
  end

  def reassociate_images
    unassociate_images
    associate_images
  end

  def cover_image
    if images.present?
      images.order(display_order: :asc).first
    else
      Image.placeholder.first
    end
  end

  private

    def extract_images
      image_paths = []
      image_paths << introduction.scan(/\/\w+.(?:jpeg|png|jpg)/).uniq
      image_paths << description.scan(/\/\w+.(?:jpeg|png|jpg)/).uniq
      image_paths << specification.scan(/\/\w+.(?:jpeg|png|jpg)/).uniq
      result_cleanup(image_paths)
    end

    def result_cleanup(image_paths)
      image_paths = image_paths.reject(&:empty?).flatten
      image_paths.map! { |image_path| image_path.delete("/") }
    end

    def reject_images(attributes)
      attributes['id'].nil? && attributes['image'].blank?
    end

end
