require 'rails_helper'

RSpec.describe ProductsHelper, type: :helper do

  let(:product) { FactoryGirl.create(:product) }
  let(:brand)   { FactoryGirl.create(:brand) }
  describe '#build_product_breadcrumb' do

    it 'returns an array with brand name and url' do
      Categorization.create(category: brand, product: product)
      result = helper.build_product_breadcrumb(product)
      expect(result).to eq([[brand.name, url_for(brand)]])
    end

    it 'returns an empty array if product does not have a brand' do
      result = helper.build_product_breadcrumb(product)
      expect(result).to eq([])
    end
  end

end
