require 'rails_helper'

RSpec.describe RewardsController, type: :controller do

  let(:customer) { FactoryBot.create(:customer) }

  before do |example|
    unless example.metadata[:skip_before]
      @ref_reward = FactoryBot.create(:ref_reward, no_products: true)
      @cash_back  = FactoryBot.create(:cash_back,  no_products: true)
      @success_order = FactoryBot.create(:payment_order, success: true)
      @referer = FactoryBot.create(:customer)
      Referral.create(referer: @referer, referee: @success_order.user)
      @success_order.products.each do |product|
        product.update(price_reward: Money.new(10000))
        product.reward_methods << @ref_reward
        product.reward_methods << @cash_back
      end
      @reward_service = RewardService.new(order_id: @success_order.id)
      @reward_service.distribute
    end
  end

  describe 'GET show' do
    it 'responses successfully', skip_before: true do
      signin_as customer
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'populates rewards' do
      signin_as @referer
      get :show, params: { id: @referer.id }
      expect(assigns(:rewards)).not_to be_empty
    end
  end

end
