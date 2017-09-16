require 'rails_helper'

RSpec.describe Wallet, type: :model do

  let(:customer) { FactoryGirl.create(:customer) }

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
end
