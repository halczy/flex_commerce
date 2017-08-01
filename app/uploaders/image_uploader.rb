require "image_processing/mini_magick"

class ImageUploader < Shrine
  include ImageProcessing::MiniMagick

  # Plugins
  plugin :validation_helpers
  plugin :determine_mime_type
  plugin :cached_attachment_data
  plugin :delete_promoted
  plugin :delete_raw
  plugin :remove_invalid
  plugin :processing
  plugin :versions

  # Validation
  Attacher.validate do
      validate_max_size 5.megabyte, message: "is too large (max is 5 MB)"
      validate_mime_type_inclusion ['image/jpg', 'image/jpeg', 'image/png']
  end

  # Versioning
  process(:store) do |io, context|
    { original: io,
      thumb: resize_to_limit!(io.download, 300, 300),
      fit: resize_to_limit!(io.download, 800, 800) }
  end
end
