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
  end

  describe '#build_carousel_inner' do
    before do
      @img_1 = FactoryGirl.create(:image)
      @img_2 = FactoryGirl.create(:image)
      @img_3 = FactoryGirl.create(:image)
      @imgs = [@img_1, @img_2, @img_3]
    end

    it 'returns carousel-inner html' do
      result = helper.build_carousel_inner(@imgs)
      expect(result).to have_css("div.carousel-item", count: 3)
      expect(result).to have_css("div.carousel-item.active", count: 1)
      expect(result).to have_css("img.d-block.w-100", count: 3)
    end

  end

end
