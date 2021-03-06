require 'rails_helper'

RSpec.describe Transfer, type: :model do

  let(:customer)       { FactoryBot.create(:customer) }
  let(:transfer)       { FactoryBot.create(:wallet_transfer) }
  let(:wallet_success) { FactoryBot.create(:wallet_transfer, success: true) }

  describe 'creation' do
    it 'creates a transfer' do
      expect(transfer).to be_valid
    end

    context 'validations' do
      it 'cannot create a transfer without amount' do
        transfer = FactoryBot.build(:wallet_transfer, amount: nil)
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer with zero as amount' do
        transfer = FactoryBot.build(:wallet_transfer, amount: Money.new(0))
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer without transferer' do
        transfer = FactoryBot.build(:wallet_transfer, transferee: nil)
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer without transferee' do
        transfer = FactoryBot.build(:wallet_transfer, transferer: nil)
        expect(transfer).not_to be_valid
      end
    end
  end

  describe 'relationships' do
    it 'has a user as transferer' do
      expect(transfer.transferer).to be_an_instance_of Customer
    end

    it 'allows transferee to refer to the transfer' do
      expect(transfer.transferer.transfer_outs).to include(transfer)
    end

    it 'has a user as transferee' do
      expect(transfer.transferee).to be_an_instance_of Customer
    end

    it 'allows transferer to refer to the transfer' do
      expect(transfer.transferee.transfer_ins).to include(transfer)
    end

    it 'has wallet as fund_source' do
      transfer.update(fund_source: transfer.transferer.wallet)
      expect(transfer.fund_source).to eq(transfer.transferer.wallet)
    end

    it 'allows transferer wallet to refer to the transfer' do
      transfer.update(fund_source: transfer.transferer.wallet)
      expect(transfer.transferer.wallet.transfer_outs).to include(transfer)
    end

    it 'has wallet as fund_target' do
      transfer.update(fund_target: transfer.transferee.wallet)
      expect(transfer.fund_target).to eq(transfer.transferee.wallet)
    end

    it 'allows transferee wallet to refer to the transfer' do
      transfer.update(fund_target: transfer.transferee.wallet)
      expect(transfer.transferee.wallet.transfer_ins).to include(transfer)
    end

    it 'has a transaction as transaction_log' do
      expect(wallet_success.transaction_log).to be_present
    end
  end
end
