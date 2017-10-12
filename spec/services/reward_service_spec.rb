require 'rails_helper'

RSpec.describe RewardService, type: :model do

  before do
    @ref_reward = FactoryGirl.create(:ref_reward, no_products: true)
    @cash_back  = FactoryGirl.create(:cash_back,  no_products: true)
    @success_order = FactoryGirl.create(:payment_order, success: true)
    @referer = FactoryGirl.create(:customer)
    Referral.create(referer: @referer, referee: @success_order.user)
    @success_order.products.each do |product|
      product.update(price_reward: Money.new(10000))
      product.reward_methods << @ref_reward
      product.reward_methods << @cash_back
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

      it 'distributes referral reward to referer' do
        exp_amount = (100 * 0.05 * 3).to_money
        allow(@reward_service).to receive(:cash_back_rewardable?) { false }
        @reward_service.distribute
        expect(@referer.wallet.reload.balance).to eq(exp_amount)
      end

      it 'creates transaction log with note' do
        @reward_service.distribute
        t = Transaction.where(processable: @referer.wallet).first
        expect(t.note).to be_present
      end

      it 'does not distribute referral reward if customer has no referer' do
        Referral.delete_all
        @reward_service.distribute
        expect(@referer.wallet.reload.balance).to eq(0)
      end

      it 'does not distribute referral if referral amount is zero' do
        Product.all.each { |p| p.update(price_reward: 0) }
        @reward_service.distribute
        expect(@reward_service.referral_amount).to eq(0)
        expect(@referer.wallet.reload.balance).to eq(0)
      end
    end

    context 'cash back' do
      it 'sums up cash back reward amount' do
        exp_amount = (100 * 0.1 * 3).to_money
        @reward_service.distribute
        expect(@reward_service.cash_back_amount).to eq(exp_amount)
      end

      it 'distributes cash back to customer' do
        FactoryGirl.create(:service_order, completed: true, user: @success_order.user)
        old_balance = @success_order.user.wallet.reload.balance
        @reward_service.distribute
        new_balance = @success_order.user.wallet.reload.balance
        expect(new_balance).to be > old_balance
      end

      it 'distributes cash back to customer reguardless of referer' do
        Referral.delete_all
        FactoryGirl.create(:service_order, completed: true, user: @success_order.user)
        old_balance = @success_order.user.wallet.reload.balance
        @reward_service.distribute
        new_balance = @success_order.user.wallet.reload.balance
        expect(new_balance).to be > old_balance
      end

      it 'distributes cash back to referer on first order' do
        @reward_service.distribute
        expect(@referer.wallet.reload.balance).not_to eq(0)
        expect(@referer.wallet.reload.withdrawable).not_to eq(0)
      end

      it 'does not distribute cash back reward if customer has no referer' do
        Referral.delete_all
        @reward_service.distribute
        expect(@referer.wallet.reload.balance).to eq(0)
      end

      it 'does not distribute cash back reward if cash back amount is zero' do
        Product.all.each { |p| p.update(price_reward: 0) }
        @reward_service.distribute
        expect(@reward_service.referral_amount).to eq(0)
        expect(@referer.wallet.reload.balance).to eq(0)
      end
    end
  end

end
