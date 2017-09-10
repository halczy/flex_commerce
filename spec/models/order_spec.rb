require 'rails_helper'

RSpec.describe Order, type: :model do

  let(:order)     { FactoryGirl.create(:order) }
  let(:new_order) { FactoryGirl.create(:new_order) }

  describe 'creation' do
    it 'can be created' do
      expect(order).to be_valid
      expect(order.status).to eq('created')
    end

    context 'validation' do
      it 'cannot be created without user|customer' do
        expect {
          FactoryGirl.create(:order, user: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'relationships' do
    context 'inventory' do
      it 'can have inventories' do
        expect(new_order).to be_valid
        expect(new_order.inventories).not_to be_empty
      end
    end
  end
end
