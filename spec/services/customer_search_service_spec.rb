require 'rails_helper'

RSpec.describe CustomerSearchService, type: :model do

  before do
    @c1 = FactoryBot.create(:customer, name: 'John Doe')
    @c2 = FactoryBot.create(:customer, name: 'Jane Doe')
    @c3 = FactoryBot.create(:customer, name: 'John Kirk')
  end

  describe '#search' do
    it 'can search for customer by ID' do
      search_run = CustomerSearchService.new(@c1.id)
      expect(search_run.search).to match_array([@c1])
    end

    it 'can search for customer by member id' do
      search_run = CustomerSearchService.new(@c1.member_id.to_s)
      expect(search_run.search).to match_array([@c1])
    end

    it 'can search for customer by name' do
      search_run = CustomerSearchService.new('Doe')
      expect(search_run.search).to match_array([@c1, @c2])
    end

    it 'can search for customer by email' do
      search_run = CustomerSearchService.new(@c3.email)
      expect(search_run.search).to match_array([@c3])
    end

    it 'can search for customer by cell number' do
      search_run = CustomerSearchService.new(@c2.cell_number)
      expect(search_run.search).to match_array([@c2])
    end
  end
end
