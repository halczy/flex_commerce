class Image < ApplicationRecord
  # Shrine
  include ImageUploader::Attachment.new(:image)

  # Relationships
  belongs_to :imageable, polymorphic: true, optional: true

  # Validations
  validates :image, presence: true
end
