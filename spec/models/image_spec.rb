require 'rails_helper'

RSpec.describe Image, type: :model do

  let(:image)   { FactoryGirl.create(:image) }
  let(:product) { FactoryGirl.create(:product) }

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

  describe '#tag' do

    before { image.tag(product.class, product.id, 1) }

    it 'creates product relationship to image' do
      expect(image.imageable).to eq(product)
    end

    it 'toggles in_use to true' do
      expect(image.in_use).to be_truthy
    end

    it 'logs the source channel' do
      expect(image.source_channel).to eq('editor')
    end
  end

  describe '#associate' do
    it 'locates the image and call tag method' do
      Image.associate(product, image.image[:fit].data['id'], 1)
      expect(image.reload.in_use).to be_truthy
      expect(image.imageable).to eq(product)
    end
  end

  describe '#untag' do

    before { image.tag(product.class, product.id, 1) }

    it 'sets relationship to nil' do
      image.untag
      expect(image.imageable).to be_nil
    end

    it 'toggles the in_use tag' do
      image.untag
      expect(image.in_use).to be_falsey
    end
  end
end
