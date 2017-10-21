FactoryBot.define do
  factory :image do
    display_order 0
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'files', 'img_1.jpeg'), 'image/jpeg') }
  end
end
