class Image < ApplicationRecord
  include ImageUploader::Attachment.new(:image)
  include TranslateEnum

  # Relationships
  belongs_to :imageable, polymorphic: true, optional: true, touch: true

  # Validations
  validates :image, presence: true

  # Scope
  scope :orphans,     -> { where(in_use: false) }
  scope :attachments, -> { where(source_channel: 0) }
  scope :placeholder, -> { where(title: 'Placeholder Image') }

  # Enum
  enum source_channel: { attachment: 0, editor: 1 }
  translate_enum :source_channel
  
  def self.associate(object, filename, source_channel)
    Image.orphans.each do |img|
      if img.image[:fit].data['id'] == filename
        img.tag(object.class, object.id, source_channel)
      end
    end
  end

  def tag(klass, id, source_channel)
    update(imageable_type: klass, imageable_id: id, in_use: true,
           source_channel: source_channel)
  end

  def untag
    unless source_channel == 'attachment'
      update(imageable_type: nil, imageable_id: nil, in_use: false,
             source_channel: nil)
    end
  end

end
