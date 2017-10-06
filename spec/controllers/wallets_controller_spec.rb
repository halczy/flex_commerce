require 'rails_helper'

RSpec.describe WalletsController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:admin)    { FactoryGirl.create(:admin) }

  describe 'GET show' do
    before { signin_as customer }

    it 'response successfully' do
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'retrives customer wallet' do
      get :show, params: { id: customer.id }
      expect(assigns(:wallet)).to eq(customer.wallet)
    end
  end

end
