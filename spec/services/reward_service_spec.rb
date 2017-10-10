require 'rails_helper'

RSpec.describe RewardService, type: :model do

  before do
    @ref_reward = FactoryGirl.create(:ref_reward, no_products: true)
    @success_order = FactoryGirl.create(:payment_order, success: true)
    @success_order.products.each do |product|
      product.update(price_reward: Money.new(10000))
      product.reward_methods << @ref_reward
    end
    @reward_service = RewardService.new(order_id: @success_order.id)
  end

  describe '#initialize' do
    it 'initializes with order id' do
      reward_service = RewardService.new(order_id: @success_order.id)
      expect(reward_service.order).to eq(@success_order)
      expect(reward_service.referral_amount).to eq(0)
    end
  end

  describe '#reward_amount' do
    describe '#referral_reward_amount' do
      it 'returns the referral reward amount' do
        inv = @success_order.inventories.sample
        ref_amount = inv.product.price_reward * 0.05
        @reward_service.send(:referral_reward_amount, inv, @ref_reward)
        expect(@reward_service.referral_amount).to eq(ref_amount)
      end
    end
  end

  describe '#distribute' do
    context 'referral' do
      it 'sums up reward amount for referral method' do
        exp_amount = (100 * 0.05 * 3).to_money
        @reward_service.distribute
        expect(@reward_service.referral_amount).to eq(exp_amount)
      end
    end
  end

end
