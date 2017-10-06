require 'rails_helper'

RSpec.describe Transfer, type: :model do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:transfer) { FactoryGirl.create(:transfer) }

  describe 'creation' do
    it 'creates a transfer' do
      expect(transfer).to be_valid
    end

    context 'validations' do
      it 'cannot create a transfer without amount' do
        transfer = FactoryGirl.build(:transfer, amount: nil)
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer with zero as amount' do
        transfer = FactoryGirl.build(:transfer, amount: Money.new(0))
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer without transferer' do
        transfer = FactoryGirl.build(:transfer, transferee: nil)
        expect(transfer).not_to be_valid
      end

      it 'cannot create a transfer without transferee' do
        transfer = FactoryGirl.build(:transfer, transferer: nil)
        expect(transfer).not_to be_valid
      end
    end
  end

  describe 'relationships' do
    it 'has a user as transferer' do
    end

    it 'has a user as transferee' do
    end
  end
end
