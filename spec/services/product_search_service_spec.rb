require 'rails_helper'

RSpec.describe ProductSearchService, type: :model do

  describe '#initialize' do
    it 'can be created' do
      search = ProductSearchService.new("")
      expect(search.where_clause).to be_blank
      expect(search.where_args).to be_empty
    end
  end

  describe '#quick_search' do
    before do
      @product_1 = FactoryGirl.create(:product, name: 'Blue Book',
                                               tag_line: 'A tag line')
      @product_2 = FactoryGirl.create(:product, name: 'Yellow Book',
                                               tag_line: 'YATL')
    end

    it 'returns the matching product' do
      search_run = ProductSearchService.new('BLUE')
      result = search_run.quick_search
      expect(result).to match_array([@product_1])
    end

    it 'returns the all matching products' do
      search_run = ProductSearchService.new('Book')
      result = search_run.quick_search
      expect(result).to match_array([@product_1, @product_2])
    end
  end
end
