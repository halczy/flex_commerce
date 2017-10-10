require 'rails_helper'

RSpec.describe RewardService, type: :model do

  before do
    @ref_reward = FactoryGirl.create(:ref_reward, no_products: true)
    @success_order = FactoryGirl.create(:payment_order, success: true)
    @success_order.products.each { |p| p.reward_methods << @ref_reward }
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

end
