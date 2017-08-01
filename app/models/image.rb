class Image < ApplicationRecord
  # Shrine
  include ImageUploader::Attachment.new(:image)

  # Relationships
  belongs_to :imageable, polymorphic: true, optional: true

  # Validations
  validates :image, presence: true

  # Scope
  scope :orphans, ->  { where(in_use: false) }

  def self.associate(object, filename)
    Image.orphans.each do |img|
      img.tag(object.class, object.id) if img.image.id == filename
    end
  end

  def tag(klass, id)
    update(imageable_type: klass, imageable_id: id, in_use: true)
  end

  def untag
    update(imageable_type: nil, imageable_id: nil, in_use: false)
  end

end
