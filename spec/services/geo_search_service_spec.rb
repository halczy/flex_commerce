require 'rails_helper'

RSpec.describe GeoSearchService, type: :model do

  describe '#initialize' do
    it 'can be created' do
      search = GeoSearchService.new('')
      expect(search.where_clause).to be_blank
      expect(search.where_args).to be_empty
    end
  end

  describe '#search' do
    before do
      @chicago = FactoryGirl.create(:city, id: '600100', name: 'Chicago')
      @springfield = FactoryGirl.create(:city, id: '600200', name: 'Springfield')
    end

    it 'returns geos with matching id' do
      search_run = GeoSearchService.new('6001')
      result = search_run.search
      expect(result).to match_array([@chicago])
    end

    it 'returns geos with matching name' do
      search_run = GeoSearchService.new('spring')
      result = search_run.search
      expect(result).to match_array([@springfield])
    end
  end

  describe 'full_search' do
    before do
      @illinois = FactoryGirl.create(:province, id: '600000', name: 'Illinois')
      @rockford = FactoryGirl.create(:city, id: '650000000000', name: 'Rockford', parent: @illinois)
      @evanston = FactoryGirl.create(:city, id: '670000000000', name: 'Evanston', parent: @illinois)
    end

    it 'returns geos with matching id and parent id' do
      search_run = GeoSearchService.new('600000')
      result = search_run.full_search
      expect(result).to match_array([@illinois, @rockford, @evanston])
    end

    it 'returns geos with matching name' do
      search_run = GeoSearchService.new('rock')
      result = search_run.full_search
      expect(result).to match_array([@rockford])
    end
  end














end
