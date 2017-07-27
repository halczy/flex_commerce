require 'rails_helper'

RSpec.describe Image, type: :model do

  let(:image) { FactoryGirl.create(:image) }

  describe 'creation' do
    it 'can be created' do
      expect(image).to be_valid
    end

    it 'image file can be attached' do
      expect(image.image_data).to include('.jpeg')
      expect(image.image_data).to include('store')
    end
  end

  describe 'validation' do
    it 'cannot be created without image file' do
      no_img_file = FactoryGirl.build(:image, image: nil)
      no_img_file.valid?
      expect(no_img_file.errors.messages[:image]).to include("can't be blank")
    end
  end
end
