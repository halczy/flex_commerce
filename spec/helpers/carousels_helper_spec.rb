require 'rails_helper'

RSpec.describe CarouselsHelper, type: :helper do

  describe '#build_carousel_indicators' do
    it 'returns carousel-indicators html' do
      expected_result = <<~INDICATORS
       <li data-target="#carouselIndicators" data-slide-to="0" class="active"></li>
       <li data-target="#carouselIndicators" data-slide-to="1"></li>
       <li data-target="#carouselIndicators" data-slide-to="2"></li>
      INDICATORS
      result = helper.build_carousel_indicators(3)
      expect(result).to eq(expected_result)
    end

    it 'returns one indicator for placeholder image if image_count is zero' do
      expected_result = <<~INDICATORS
       <li data-target="#carouselIndicators" data-slide-to="0" class="active"></li>
      INDICATORS
      result = helper.build_carousel_indicators(0)
      expect(result).to eq(expected_result)
    end
  end

  describe '#build_carousel_inner' do
    it 'returns carousel-inner html' do
      img_1 = FactoryBot.create(:image)
      img_2 = FactoryBot.create(:image)
      img_3 = FactoryBot.create(:image)
      imgs = [img_1, img_2, img_3]
      result = helper.build_carousel_inner(imgs)
      expect(result).to have_css("div.carousel-item", count: 3)
      expect(result).to have_css("div.carousel-item.active", count: 1)
      expect(result).to have_css("img.d-block.w-100", count: 3)
    end

    it 'returns one carousel-inner if image array is empty' do
      product = FactoryBot.create(:product)
      FactoryBot.create(:image, title: 'Placeholder Image')
      result = helper.build_carousel_inner(product.images)
      expect(result).to have_css("div.carousel-item.active", count: 1)
      expect(result).to have_css("img.d-block.w-100", count: 1)
    end

  end

end
