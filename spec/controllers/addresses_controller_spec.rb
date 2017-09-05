require 'rails_helper'

RSpec.describe AddressesController, type: :controller do

  let(:customer)  { FactoryGirl.create(:customer) }
  let(:community) { FactoryGirl.create(:community) }
  let(:valid_attrs) { FactoryGirl.attributes_for(:address) }

  before { community }  # populate selector

  describe 'GET new' do
    it 'response successfully' do
      signin_as(customer)
      get :new
      expect(response).to be_success
    end

    describe 'access control' do
      it 'redirects to sign in page if user is not signed in' do
        get :new
        expect(response).to redirect_to(signin_path)
      end
    end
  end

  describe 'POST create' do
    before { signin_as(customer) }

    context 'with valid params' do
      it 'creates a new address' do
        expect {
          post :create, params: { address: valid_attrs }
        }.to change(Address, :count).by(1)
      end

      it 'creates a new address that associates with user' do
        expect post :create, params: { address: valid_attrs }
        expect(Address.last.addressable).to eq(customer)
      end

      xit 'redirects to address index' do

      end
    end

    context 'with invalid params' do
      it 'renders back to new action' do
        post :create, params: { address: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end


end
