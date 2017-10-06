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
end
