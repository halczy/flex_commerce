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

  describe 'PATCH approve' do
    context 'with valid conditions' do
      before do
        bank_transfer.transferer.wallet.update(pending: 100.to_money)
        Transaction.create(
          amount: 100.to_money,
          transactable: bank_transfer,
          originable: bank_transfer.fund_source,
          processable: bank_transfer.fund_source,
          note: "PENDING: Withdraw to bank account."
        )
      end

      it 'displays success flash and redirect to show on success transfer' do
        patch :approve, params: { id: bank_transfer }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_transfer_path(bank_transfer))
      end
    end

    context 'with invalid conditions' do
      it 'displays warning flash and redirect to show on failure' do
        patch :approve, params: { id: bank_transfer }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(admin_transfer_path(bank_transfer))
      end
    end
  end
end
