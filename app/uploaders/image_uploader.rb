class ImageUploader < Shrine
  # Plugins
  plugin :validation_helpers
  plugin :determine_mime_type
  plugin :cached_attachment_data
  plugin :delete_promoted
  plugin :delete_raw
  plugin :remove_invalid

  # Validation
  Attacher.validate do
      validate_max_size 5.megabyte, message: "is too large (max is 5 MB)"
      validate_mime_type_inclusion ['image/jpg', 'image/jpeg', 'image/png']
  end
end
