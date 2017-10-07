require 'rails_helper'

RSpec.describe WalletsController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:admin)    { FactoryGirl.create(:admin) }

  before { signin_as customer }

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'retrives customer wallet' do
      get :show, params: { id: customer.id }
      expect(assigns(:wallet)).to eq(customer.wallet)
    end
  end

  describe 'GET show_transactions' do
    it 'responses successfully' do
      get :show_transactions, params: { id: customer.id }
      expect(response).to be_success
    end
  end

  describe 'GET show_transfer_ins' do
    it 'responses successfully' do
      get :show_transfer_ins, params: { id: customer. id }
      expect(response).to be_success
    end
  end

end
