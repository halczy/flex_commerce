require 'rails_helper'

RSpec.describe TransferService, type: :model do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:transfer) { FactoryGirl.create(:transfer) }

  describe '#initialize' do
    it 'can be initialize with transferer transferee and amount' do
      c1 = FactoryGirl.create(:customer)
      c2 = FactoryGirl.create(:customer)
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
    end
  end

  describe '#create' do
    context 'with valid params' do
      it 'returns true if a transfer is created' do
        c1 = FactoryGirl.create(:wealthy_customer)
        c2 = FactoryGirl.create(:customer)
        ts = TransferService.new(
          transferer_id: c1.id,
          transferee_id: c2.id,
          amount: '200'
        )
        expect(ts.create).to be_truthy
        expect(Transfer.count).to eq(1)
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
        c1 = FactoryGirl.create(:wealthy_customer)
        c2 = FactoryGirl.create(:customer)
        ts = TransferService.new(transferer_id: c1.id, transferee_id: c2.id)
        expect(ts.create).to be_falsey
      end

      it 'returns false if transfer is sent to transferer' do
        ts = TransferService.new(
          transferer_id: customer.id,
          transferee_id: customer.id,
          amount: '300'
        )
      end
    end
  end
end
