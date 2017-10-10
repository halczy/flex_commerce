require 'rails_helper'

RSpec.describe RewardService, type: :model do

  before do
    @ref_reward = FactoryGirl.create(:ref_reward, no_products: true)
    @success_order = FactoryGirl.create(:payment_order, success: true)
    @success_order.products.each { |p| p.reward_methods << @ref_reward }
  end

  describe '#initialize' do
    it 'initializes with order id' do
      reward_service = RewardService.new(order_id: @success_order.id)
      expect(reward_service.order).to eq(@success_order)
    end
  end

end
