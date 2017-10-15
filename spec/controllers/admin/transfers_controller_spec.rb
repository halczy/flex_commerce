require 'rails_helper'

RSpec.describe Admin::TransfersController, type: :controller do

  let(:admin)                   { FactoryGirl.create(:admin) }
  let(:wallet_transfer)         { FactoryGirl.create(:wallet_transfer) }
  let(:success_wallet_transfer) { FactoryGirl.create(:wallet_transfer, success: true) }
  let(:bank_transfer)           { FactoryGirl.create(:bank_transfer) }
  let(:success_bank_transfer)   { FactoryGirl.create(:bank_transfer, success: true) }
  let(:alipay_transfer)         { FactoryGirl.create(:alipay_transfer) }
  let(:success_alipay_transfer) { FactoryGirl.create(:alipay_transfer, success: true) }

  before { signin_as admin }

  describe 'GET index' do
    it 'reponses successfully' do
      get :index
      expect(response).to be_success
    end
  end
end
