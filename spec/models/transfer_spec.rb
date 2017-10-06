require 'rails_helper'

RSpec.describe Transfer, type: :model do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:transfer) { FactoryGirl.create(:transfer) }

  describe 'creation' do
    it 'creates a transfer' do
      expect(transfer).to be_valid
    end

    context 'validation' do
    end
  end

  describe 'relationships' do
    it 'has a user as transferer' do
    end
  end
end
