require 'rails_helper'

RSpec.describe Wallet, type: :model do

  let(:customer)         { FactoryGirl.create(:customer) }
  let(:wealthy_customer) { FactoryGirl.create(:wealthy_customer) }

  describe 'creation' do
    it 'can be created with user' do
      expect(customer.wallet).to be_present
    end

    it 'cannot be standalone' do
      expect { Wallet.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'deletion' do
    it 'cannot be deleted from user' do
      expect(customer.wallet.destroy).to be_falsey
    end
  end

  describe '#available_fund' do
    it 'returns the amount of spendable fund in wallet' do
      wealthy_customer.wallet.update(pending: 99900)
      expect(wealthy_customer.wallet.reload.available_fund).to eq(Money.new(9900))
    end

    it 'returns balance if there is not pending fund' do
      expect(wealthy_customer.wallet.reload.available_fund).to eq(Money.new(9999900))
    end
  end

  describe '#sufficient_fund' do
    it 'returns true if wallet have the query amount' do
      result = wealthy_customer.wallet.sufficient_fund?(Money.new(100000))
      expect(result).to be_truthy
    end

    it 'returns false if available fund does not have the query amount' do
      wealthy_customer.wallet.update(pending: 99998)
      result = wealthy_customer.wallet.sufficient_fund?(Money.new(200))
      expect(result).to be_falsey
    end

    it 'returns false if balance smaller than the query amount' do
      expect(customer.wallet.sufficient_fund?(Money.new(1))).to be_falsey
    end
  end

  describe '#credit' do
    it 'adds fund to user balance' do
      customer.wallet.credit(Money.new(100))
      expect(customer.reload.wallet.balance).to eq(Money.new(100))
    end

    it 'adds fund to user withdrawable' do
      customer.wallet.credit(100.to_money)
      expect(customer.reload.wallet.withdrawable).to eq(Money.new(10000))
    end

    context 'invalid credit amount' do
      it 'rejects negative credit amount' do
        result = wealthy_customer.wallet.credit(Money.new(-100))
        expect(result).to be_falsey
      end

      it 'rejects zero credit' do
        result = customer.wallet.credit(Money.new(0))
        expect(result).to be_falsey
      end
    end
  end

  describe '#conditional_credit' do
    it 'adds fund to balance but not withdrawable' do
      customer.wallet.conditional_credit(100.to_money)
      expect(customer.wallet.reload.withdrawable).to eq(0)
      expect(customer.wallet.reload.balance.to_s).to eq('100.00')
    end
  end

  describe '#debit' do
    it 'deducts fund from wallet' do
      result = wealthy_customer.wallet.debit(Money.new(100))
      expect(wealthy_customer.reload.wallet.balance).to eq(Money.new(9999800))
    end

    context '#sync_withdrawable' do
      it 'deducts fund from withdrawable if balance is equal to withdrawable' do
        result = wealthy_customer.wallet.debit(Money.new(100))
        expect(wealthy_customer.reload.wallet.withdrawable).to eq(Money.new(9999800))
      end

      it 'deducts fund from withdrawable if balance is lower than withdrawable' do
        customer.wallet.update(balance: 150.to_money, withdrawable: 100.to_money)
        customer.wallet.debit(130.to_money)
        expect(customer.wallet.reload.balance).to eq(20.to_money)
        expect(customer.wallet.reload.withdrawable).to eq(20.to_money)
      end
    end

    it 'does not deducts fund from withdrawable if balance is greater than withdrawable' do
    end

    context 'invalid debit amount' do
      it 'rejects negative deduction' do
        result = customer.wallet.debit(Money.new(-100))
        expect(result).to be_falsey
      end

      it 'rejects deduction more than available fund' do
        result = customer.wallet.debit(Money.new(100))
        expect(result).to be_falsey
      end
    end
  end
end
