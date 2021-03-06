require 'rails_helper'

RSpec.describe TransferService, type: :model do

  let(:customer) { FactoryBot.create(:customer) }
  let(:transfer) { FactoryBot.create(:wallet_transfer) }

  describe '#initialize' do
    it 'can be initialize with transferer transferee and amount' do
      c1 = FactoryBot.create(:customer)
      c2 = FactoryBot.create(:customer)
      transfer_service = TransferService.new(
        transferer_id: c1,
        transferee_id: c2,
        amount: 100
      )

      expect(transfer_service).to be_an_instance_of TransferService
      expect(transfer_service.transferer).to eq(c1)
      expect(transfer_service.transferee).to eq(c2)
      expect(transfer_service.amount.to_s).to eq("100.00")
    end

    it 'can be initialize by transfer id' do
      transfer_service = TransferService.new(transfer_id: transfer.id)
      expect(transfer_service.transferer).to eq(transfer.transferer)
      expect(transfer_service.transferee).to eq(transfer.transferee)
      expect(transfer_service.amount).to eq(transfer.amount)
      expect(transfer_service.processor).to eq('wallet')
    end
  end

  describe '#create' do
    context 'with valid params' do
      it 'returns true if a wallet transfer is created' do
        c1 = FactoryBot.create(:wealthy_customer)
        c2 = FactoryBot.create(:customer)
        ts = TransferService.new(
          transferer_id: c1.id,
          transferee_id: c2.id,
          amount: '200'
        )
        expect(ts.create).to be_truthy
        expect(Transfer.count).to eq(1)
      end

      it 'returns true if a bank transfer is created' do
        cstm = FactoryBot.create(:wealthy_customer)
        ts = TransferService.new(
          transferer_id: cstm.id,
          transferee_id: cstm.id,
          processor: 'bank',
          amount: '300'
        )
        expect(ts.create).to be_truthy
        expect(Transfer.first.pending?).to be_truthy
      end

      it 'returns true if an alipay transfer is created' do
        cstm = FactoryBot.create(:wealthy_customer)
        ts = TransferService.new(
          transferer_id: cstm.id,
          transferee_id: cstm.id,
          processor: 'alipay',
          amount: '300'
        )
        expect(ts.create).to be_truthy
        expect(Transfer.first.pending?).to be_truthy
      end

      it 'withhold funds upon external transfer creation' do
        cstm = FactoryBot.create(:wealthy_customer)
        ts = TransferService.new(
          transferer_id: cstm.id,
          transferee_id: cstm.id,
          processor: 'bank',
          amount: '300'
        )
        old_balance = cstm.wallet.balance
        ts.create
        new_balance = cstm.wallet.reload.balance
        expect(old_balance - new_balance).to eq('300'.to_money)
        expect(cstm.wallet.reload.pending).to eq('300'.to_money)
      end

      it 'creates transaction upon external transfer creation' do
        cstm = FactoryBot.create(:wealthy_customer)
        ts = TransferService.new(
          transferer_id: cstm.id,
          transferee_id: cstm.id,
          processor: 'alipay',
          amount: '300'
        )
        expect { ts.create }.to change(Transaction, :count).by(1)
        expect(Transaction.first.amount).to eq('300'.to_money)
        expect(Transaction.first.transactable).to eq(Transfer.first)
        expect(Transaction.first.originable).to eq(cstm.wallet)
        expect(Transaction.first.processable).to eq(cstm.wallet)
      end
    end

    context 'with invalid params or conditions' do
      it 'returns false if transferee is not set' do
        ts = TransferService.new(transferer_id: customer.id, amount: '200')
        expect(ts.create).to be_falsey
      end

      it 'returns false if transferer is not set' do
        ts = TransferService.new(transferee_id: customer.id, amount: '100')
        expect(ts.create).to be_falsey
      end

      it 'returns false if amount is not set' do
        c1 = FactoryBot.create(:wealthy_customer)
        c2 = FactoryBot.create(:customer)
        ts = TransferService.new(transferer_id: c1.id, transferee_id: c2.id)
        expect(ts.create).to be_falsey
      end

      it 'returns false if transferer is transferee' do
        ts = TransferService.new(
          transferer_id: customer.id,
          transferee_id: customer.id,
          amount: '300'
        )
      end
    end
  end

  describe '#wallet_transfer' do
    before do
      @c1 = FactoryBot.create(:wealthy_customer)
      @c2 = FactoryBot.create(:customer)
      @transfer_service = TransferService.new(
        transferer_id: @c1.id,
        transferee_id: @c2.id,
        amount: '200'
      )
      @transfer_service.create
    end

    context 'with valid conditions' do
      it 'returns true if transfer is successful' do
        expect(@transfer_service.execute_transfer).to be_truthy
      end

      it 'debits transferer wallet' do
        @transfer_service.execute_transfer
        expect(@c1.wallet.reload.balance.to_s).to eq('99799.00')
      end

      it 'credits transferee wallet' do
        @transfer_service.execute_transfer
        expect(@c2.wallet.reload.balance.to_s).to eq('200.00')
      end

      it 'updates transfer status' do
        @transfer_service.execute_transfer
        expect(@transfer_service.transfer.success?).to be_truthy
      end

      it 'creates transactions' do
        expect {
          @transfer_service.execute_transfer
        }.to change(Transaction, :count).by(1)
        expect(Transaction.last.transactable).to eq(@transfer_service.transfer)
        expect(Transaction.last.originable).to eq(@c2.wallet)
        expect(Transaction.last.processable).to eq(@c1.wallet)
        expect(Transaction.last.amount).to eq(@transfer_service.amount)
        expect(Transaction.last.note).to be_present
      end
    end

    context 'with invalid conditions' do
      it 'returns false if transferer is transferee' do
        @transfer_service.transfer.update(transferee: @c1)
        expect(@transfer_service.execute_transfer).to be_falsey
      end

      it 'returns false if transferer does not have sufficient fund' do
        @transfer_service.transfer.update(amount: 9999999999)
        expect(@transfer_service.execute_transfer).to be_falsey
      end
    end
  end

  describe '#bank_transfer' do
    before do
        @cstm = FactoryBot.create(:wealthy_customer)
        ts = TransferService.new(
          transferer_id: @cstm.id,
          transferee_id: @cstm.id,
          processor: 'bank',
          amount: '300'
        )
        ts.create
    end

    context 'execute transfer' do
      it 'returns true when bank transfer is successful' do
        ts = TransferService.new(transfer_id: Transfer.first)
        expect(ts.execute_transfer).to be_truthy
        expect(ts.transfer.success?).to be_truthy
      end

      it 'removes fund from pending' do
        ts = TransferService.new(transfer_id: Transfer.first)
        ts.execute_transfer
        expect(@cstm.wallet.reload.pending).to eq(0)
      end
    end

    context 'cancel transfer' do
      it 'returns true when bank transfer is canceled' do
        ts = TransferService.new(transfer_id: Transfer.first)
        expect(ts.cancel_transfer).to be_truthy
        expect(ts.transfer.failure?).to be_truthy
      end

      it 'removes transfer funding back to wallet' do
        ts = TransferService.new(transfer_id: Transfer.first)
        ts.cancel_transfer
        expect(@cstm.wallet.reload.pending).to eq(0)
        expect(@cstm.wallet.reload.balance).to eq('99999'.to_money)
        expect(@cstm.wallet.reload.withdrawable).to eq('99999'.to_money)
      end

      it 'updates transaction log' do
        ts = TransferService.new(transfer_id: Transfer.first)
        ts.cancel_transfer
        expect(ts.transfer.transaction_log.note).to include('REJECTED')
      end
    end
  end

  describe '#alipay_transfer' do
    before do
      @cstm = FactoryBot.create(:wealthy_customer)
      @cstm.update(settings: { alipay_account: 'abc@example.com' })
      @ts = TransferService.new(
         transferer_id: @cstm.id,
         transferee_id: @cstm.id,
         processor: 'alipay',
         amount: '300'
      )
      @ts.create
    end

    context 'with valid params' do
      before do
        stub_request(:post, "https://openapi.alipaydev.com/gateway.do").
          to_return(body: {
            alipay_fund_trans_toaccount_transfer_response: {
              code: '10000',
              out_biz_no: @ts.transfer.id,
              order_id: '1234567890'
            }
          }.to_json, status: 200)
      end

      it 'returns true when alipay transfer is sent successfully' do
        expect(@ts.execute_transfer).to be_truthy
      end

      it 'logs alipay response' do
        @ts.execute_transfer
        expect(@ts.transfer.processor_response).to be_present
      end

      it 'withdraws transfer amount from pending' do
        @ts.execute_transfer
        expect(@ts.transferer.wallet.reload.pending).to eq(0)
      end

      it 'updates transfer status and transaction log' do
        @ts.execute_transfer
        expect(@ts.transfer.reload.success?).to be_truthy
        expect(@ts.transfer.reload.transaction_log.note).to include('SUCCESS')
      end
    end

    context 'with invalid params' do
      before do
        stub_request(:post, "https://openapi.alipaydev.com/gateway.do").
          to_return(body: {
            alipay_fund_trans_toaccount_transfer_response: {
              code: '20000',
              msg: 'Service Currently Unavailable'
            }
          }.to_json, status: 200)
      end

      it 'sets payment status to failure when alipay fail to process' do
        @ts.execute_transfer
        expect(@ts.transfer.reload.failure?).to be_truthy
      end
    end

    context 'cancal transfer' do
      it 'cancels alipay transfer' do
        @ts.cancel_transfer
        expect(@ts.transfer.failure?).to be_truthy
      end

      it 'returns withheld fund to transferer' do
        @ts.cancel_transfer
        expect(@ts.transferer.wallet.reload.pending).to eq(0)
      end
    end

    context 'manual alipay transfer' do
      it 'sets transfer to success status' do
        @ts.manual_alipay_transfer
        expect(@ts.transfer.reload.success?).to be_truthy
      end

      it 'withdraws transfer amount from pending' do
        @ts.manual_alipay_transfer
        expect(@ts.transferer.wallet.reload.pending).to eq(0)
      end
    end
  end
end
