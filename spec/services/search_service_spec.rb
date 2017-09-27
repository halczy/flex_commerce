require 'rails_helper'

RSpec.describe SearchService, type: :model do

  let(:search_run) { SearchService.new('MyProduct') }

  describe "#initialize" do
    it 'returns a new instance' do
      expect(search_run).to be_an_instance_of(SearchService)
      expect(search_run.where_clause).to eq("")
      expect(search_run.where_args).to eq({})
    end
  end

  describe '#build_clause' do
    it 'returns where clause' do
      result = search_run.build_clause('name')
      expect(result).to eq('CAST(name AS TEXT) ILIKE :name')
    end
  end

  describe '#build_args' do
    it 'returns where args' do
      result = search_run.build_args
      expect(result).to eq('%MyProduct%')
    end
  end

  describe '#build' do
    context 'where_clause' do
      it 'builds valid query clause with single field_name' do
        search_run.build('description')
        expect(search_run.where_clause).to eq(
          "CAST(description AS TEXT) ILIKE :description"
        )
      end

      it 'builds valid query clause with multiple field_name' do
        search_run.build('name', 'tag_line')
        expect(search_run.where_clause).to eq(
         "CAST(name AS TEXT) ILIKE :name OR CAST(tag_line AS TEXT) ILIKE :tag_line"
        )
      end
    end

    context 'where_args' do
      it 'builds valid query argument with single field_name ' do
        search_run.build('title')
        expect(search_run.where_args).to eq({title: '%MyProduct%'})
      end

      it 'builds valid query argument with multiple field_name' do
        search_run.build('title', 'cell_number')
        expect(search_run.where_args).to eq(
          {title: "%MyProduct%", cell_number: "%MyProduct%" }
        )
      end
    end

    it 'raises error when no argument is provided' do
      expect{search_run.build}.to raise_error(ArgumentError)
    end
  end

end
