class Product < ApplicationRecord
  include TranslateEnum
  
  # Realtionships
  has_many :categorizations, dependent: :destroy
  has_many :categories,      through: :categorizations
  has_many :images,          as: :imageable, dependent: :destroy
  has_many :inventories,     dependent: :destroy
  has_and_belongs_to_many :shipping_methods
  has_and_belongs_to_many :reward_methods

  # Nested form
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :reject_images

  # Validations
  validates :name,   presence: true, length: { maximum: 30 }
  validates :weight, presence: true
  validates_with ShippingMethodValidator
  validates_with RewardMethodValidator
  monetize :price_market_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_member_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_reward_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :cost_cents,         numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :in_stock, -> { joins(:inventories).merge(Inventory.available) }
  scope :out_of_stock, -> { where.not(id: in_stock) }

  # Enum
  enum status: { disabled: 0, active: 1 }
  translate_enum :status
  
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

  def add_inventories(amount = 1)
    amount.to_i.times { add_inventory }
  end

  def remove_inventories(amount = nil)
    amount = inventories.unsold.count if amount.nil?
    return false if amount.to_i > inventories.unsold.count
    amount.to_i.times { remove_inventory }
  end

  def force_remove_inventories(amount = nil)
    amount = inventories.destroyable.count if amount.nil?
    return false if amount.to_i > inventories.destroyable.count
    amount.to_i.times { remove_inventory }
  end

  def destroyable?
    inventories.undestroyable.count <= 0
  end

  def disable
    disabled!
    force_remove_inventories
  end

  def in_stock?
    inventories.available.count > 0
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

    def add_inventory
      inventories.create(status: 0)
    end

    def remove_inventory
      remove_queue = inventories.destroyable.try(:order, {status: :asc}).
                                             try(:order, {updated_at: :desc})
      remove_queue.present? ? remove_queue.first.destroy : false
    end

end
