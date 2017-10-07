require 'rails_helper'

RSpec.describe TransactionsHelper, type: :helper do

  let(:completed_order) { FactoryGirl.create(:service_order, completed: true)}

  describe '#payment_source' do
    before do
      @wallet_transaction =  Transaction.create(amount: completed_order.total,
                                                originable: completed_order.payments.first,
                                                transactable: completed_order,
                                                processable: completed_order.user.wallet)
    end

    it "returns source via processable type if it exists" do
      wallet_transaction =  Transaction.create(amount: completed_order.total,
                                               originable: completed_order.payments.first,
                                               transactable: completed_order,
                                               processable: completed_order.user.wallet)
      expect(helper.payment_source(wallet_transaction)).to eq('Wallet')
    end

    it "returns source via payment" do
      completed_order.payments.first.alipay!
      alipay_transaction =  Transaction.create(amount: completed_order.total,
                                               originable: completed_order.payments.first,
                                               transactable: completed_order)
      expect(helper.payment_source(alipay_transaction)).to eq('Alipay')
    end
  end

  describe '#amount_direction' do
    before do
      @c1 = FactoryGirl.create(:wealthy_customer)
      @c2 = FactoryGirl.create(:customer)
      @transfer_service = TransferService.new(
        transferer_id: @c1.id,
        transferee_id: @c2.id,
        amount: '200'
      )
      @transfer_service.create
      @transfer_service.execute_transfer
    end

    it 'returns debit if transaction processable is given user wallet' do
      result = helper.amount_direction(@c1, @transfer_service.transfer.transaction_log)
      expect(result).to eq('Debit')
    end

    it 'returns credit if transaction processable is given user wallet' do
      result = helper.amount_direction(@c2, @transfer_service.transfer.transaction_log)
      expect(result).to eq('Credit')
    end
  end

end
