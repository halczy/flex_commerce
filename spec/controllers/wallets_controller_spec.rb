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
      get :show_transfer_ins, params: { id: customer.id }
      expect(response).to be_success
    end
  end

  describe 'GET show_transfer_outs' do
    it 'responses successfully' do
      get :show_transfer_outs, params: { id: customer.id }
      expect(response).to be_success
    end
  end

  describe 'GET new_withdraw' do
    it 'responses successfully' do
      customer.update(settings: { alipay_account: '1@1.com' })
      get :new_withdraw, params: { id: customer.reload.id }
      expect(response).to be_success
    end

    it 'redirects to user profile edit if neither bank nor alipay is present' do
      get :new_withdraw, params: { id: customer.id }
      expect(response).to redirect_to(edit_customer_path(customer))
    end
  end

  describe 'POST create_withdraw' do
    context 'with valid params' do
      before do
        customer.wallet.update(withdrawable: 100.to_money, balance: 100.to_money)
      end

      it 'creates bank withdraw transfer' do
        expect {
          post :create_withdraw, params: {
            id: customer.id,
            processor: 'bank',
            amount: '100'.to_money
          }
        }.to change(Transfer, :count).by(1)
      end

      it 'redirects to withdraw show view' do
        post :create_withdraw, params: { id: customer.id,
                                         processor: 'bank', amount: '100'.to_money }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(show_withdraw_wallet_path(Transfer.last))
      end
    end

    context 'with invalid params' do
      it 'does not create transfer if withdraw amount is larger than avialable fund' do
        expect {
          post :create_withdraw, params: {
            id: customer.id,
            processor: 'bank',
            amount: '100'.to_money
          }
        }.to change(Transfer, :count).by(0)
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(new_withdraw_wallet_path(customer))
      end

      it 'does not create transfer if invalid proceesor is provided' do
        customer.wallet.update(withdrawable: 100.to_money, balance: 100.to_money)
        post :create_withdraw, params: { id: customer.id,
                                         processor: 'a', amount: '100'.to_money }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(new_withdraw_wallet_path(customer))
      end
    end
  end

  describe 'GET show_withdraw' do
    before do
      customer.wallet.update(withdrawable: 100.to_money, balance: 100.to_money)
      post :create_withdraw, params: {
            id: customer.id,
            processor: 'bank',
            amount: '100'.to_money
      }
      @transfer = Transfer.all.first
    end

    it 'responses successfully' do
      get :show_withdraw, params: { id: customer.id, transfer_id: @transfer.id }
      expect(response).to be_success
    end
  end
end
