require 'rails_helper'

RSpec.describe OrderSearchService, type: :model do

  let(:customer)        { FactoryBot.create(:customer) }
  let(:order)           { FactoryBot.create(:order, user: customer) }
  let(:order_confirmed) { FactoryBot.create(:order, confirmed: true, user: customer) }

  describe '#search' do
    before do
      @customer_1 = FactoryBot.create(:customer)
      @customer_2 = FactoryBot.create(:customer, name: 'TESTNAME')
      @c1_order_1 = FactoryBot.create(:order, user: @customer_1)
      @c1_order_2 = FactoryBot.create(:order, user: @customer_1, confirmed: true)
      @c2_order_1 = FactoryBot.create(:order, user: @customer_2)
      @c2_order_2 = FactoryBot.create(:order, user: @customer_2, confirmed: true)
    end

    it 'can search order by customer id' do
      search_run = OrderSearchService.new(@customer_1.id)
      result = search_run.search
      expect(result).to match_array([@c1_order_1, @c1_order_2])
    end

    it 'can search order by customer name' do
      search_run = OrderSearchService.new(@customer_2.name)
      result = search_run.search
      expect(result).to match_array([@c2_order_1, @c2_order_2])
    end

    it 'can search order by customer member id' do
      search_run = OrderSearchService.new(@customer_2.member_id.to_s)
      result = search_run.search
      expect(result).to match_array([@c2_order_1, @c2_order_2])
    end

    it 'can serach order by order id' do
      search_run = OrderSearchService.new(@c1_order_2.id)
      result = search_run.search
      expect(result).to match_array([@c1_order_2])
    end
  end
end
