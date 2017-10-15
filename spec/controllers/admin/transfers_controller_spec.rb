require 'rails_helper'

RSpec.describe Admin::TransfersController, type: :controller do

  let(:admin)            { FactoryGirl.create(:admin) }
  let(:wallet_transfer)  { FactoryGirl.create(:wallet_transfer) }
  let(:wallet_success)   { FactoryGirl.create(:wallet_transfer, success: true) }
  let(:bank_transfer)    { FactoryGirl.create(:bank_transfer) }
  let(:bank_success)     { FactoryGirl.create(:bank_transfer, success: true) }
  let(:alipay_transfer)  { FactoryGirl.create(:alipay_transfer) }
  let(:alipay_success)   { FactoryGirl.create(:alipay_transfer, success: true) }

  before { signin_as admin }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end

    context 'filter' do
      before do
        @wallet_transfer = wallet_transfer
        @wallet_success = wallet_success
        @bank_transfer = bank_transfer
        @bank_success = bank_success
      end

      it 'displays all wallet transfers' do
        get :index, params: { filter: 'wallet' }
        expect(assigns(:transfers)).to match_array([@wallet_transfer, @wallet_success])
      end

      it 'displays all bank transfers' do
        get :index, params: { filter: 'bank' }
        expect(assigns(:transfers)).to match_array([@bank_transfer, @bank_success])
      end

      it 'displays all created transfers' do
        get :index, params: { filter: 'created' }
        expect(assigns(:transfers)).to match_array([@wallet_transfer, @bank_transfer])
      end

      it 'displays all success transfers' do
        get :index, params: { filter: 'success' }
        expect(assigns(:transfers)).to match_array([@wallet_success, @bank_success])
      end
    end
  end

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: wallet_transfer }
      expect(response).to be_success
    end
  end
end
