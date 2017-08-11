require 'rails_helper'

RSpec.describe ProductSearchService, type: :model do

  describe '#initialize' do
    it 'can be created' do
      search = ProductSearchService.new("")
      expect(search.where_clause).to be_blank
      expect(search.where_args).to be_empty
    end
  end

end
