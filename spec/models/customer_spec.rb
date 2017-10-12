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
    it 'sums up customer payment success orders total' do
      qo_1 = FactoryGirl.create(:service_order, user: customer, completed: true)
      qo_2 = FactoryGirl.create(:payment_order, user: customer, success: true)
      FactoryGirl.create(:order, user: customer)
      exp_total = qo_1.total + qo_2.total
      expect(customer.total_spent).to eq(exp_total)
    end
  end

  describe '#reward_income' do
    it 'sums up customer reward amount' do
      3.times do
        payment_service = PaymentService.new(
          order_id: FactoryGirl.create(:service_order, completed: true).id,
          amount: 150.to_money,
          user_id: customer.id,
          variety: 'reward'
        )
        payment_service.create
        payment_service.reward
      end
      expect(customer.reward_income).to eq(450.to_money)
    end
  end
end
