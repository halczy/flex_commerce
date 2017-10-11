require 'rails_helper'

RSpec.describe Customer, type: :model do

  let(:customer)        { FactoryGirl.create(:customer) }
  let(:completed_order) { FactoryGirl.create(:service_order, completed: true) }

  describe 'creation' do
    it 'can be created' do
      expect(customer).to be_valid
      expect(customer.type).to eq('Customer')
    end
  end

  describe '#customer?' do
    it 'returns true when user is an admin' do
      expect(customer.customer?).to be_truthy
    end
  end

  describe '#total_spent' do
    it 'sums up customer payment success orders total ' do
      qo_1 = FactoryGirl.create(:service_order, user: customer, completed: true)
      qo_2 = FactoryGirl.create(:payment_order, user: customer, success: true)
      FactoryGirl.create(:order, user: customer)
      exp_total = qo_1.total + qo_2.total
      expect(customer.total_spent).to eq(exp_total)
    end
  end

end
