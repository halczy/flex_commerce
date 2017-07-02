require 'rails_helper'

RSpec.describe Admin, type: :model do

  let(:admin) { FactoryGirl.create(:admin) }

  describe 'creation' do
    it 'can be created' do
      expect(admin).to be_valid
      expect(admin.type).to eq('Admin')
    end
  end

  describe '#admin?' do
    it 'returns true when user is an admin' do
      expect(admin.admin?).to be_truthy
    end

    it 'returns false when user is not an admin' do
      customer = FactoryGirl.create(:customer)
      expect(customer.admin?).to be_falsy
    end
  end

end
