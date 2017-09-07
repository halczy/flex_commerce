module ImagesHelpers
  def create_placeholder_image
    Image.create(title: "Placeholder Image",
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))
  end
end

RSpec.configure do |c|
  c.include ImagesHelpers
end
