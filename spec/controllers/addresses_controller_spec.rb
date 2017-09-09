require 'rails_helper'

RSpec.describe AddressesController, type: :controller do

  let(:customer)    { FactoryGirl.create(:customer) }
  let(:community)   { FactoryGirl.create(:community) }
  let(:valid_attrs) { FactoryGirl.attributes_for(:address) }
  let(:new_attrs)   { FactoryGirl.attributes_for(:address) }
  let(:address)     { FactoryGirl.create(:address, addressable: customer) }

  before { community }  # populate selector

  describe 'GET index' do
    before do
      5.times { FactoryGirl.create(:address, addressable: customer) }
    end

    it 'returns a success response' do
      signin_as(customer)
      get :index
      expect(response).to be_success
    end

    it 'only returns current customer addresses' do
      another_customer = FactoryGirl.create(:customer)
      signin_as(another_customer)
      get :index
    expect(assigns(:addresses)).to be_empty
    end
  end

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

      it 'redirects to address index' do
        expect post :create, params: { address: valid_attrs }
        expect(response).to redirect_to(addresses_path)
      end
    end

    context 'with invalid params' do
      it 'renders back to new action' do
        post :create, params: { address: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    before { signin_as(customer) }

    it "response successfully" do
      get :edit, params: { id: address.id }
      expect(response).to be_success
    end

    it "sets address" do
      get :edit, params: { id: address.id }
      expect(assigns(:address)).to eq(address)
    end

    it "populates address selector" do
      get :edit, params: { id: address.id }
      expect(assigns(:province).id).to eq(address.province_state)
      expect(assigns(:city).id).to eq(address.city)
      expect(assigns(:district).id).to eq(address.district)
      expect(assigns(:community).id).to eq(address.community)
    end
  end

  describe 'PATCH update' do
    before { signin_as(customer) }
    context 'with valid params' do
      it 'updates the requested address' do
        patch :update, params: { id: address.id, address: new_attrs }
        address.reload
        expect(address.recipient).to eq(new_attrs[:recipient])
        expect(address.province_state).to eq(new_attrs[:province_state])
        expect(address.community).to eq(new_attrs[:community])
      end

      it 'redirects to address index' do
        patch :update, params: { id: address.id, address: new_attrs }
        expect(response).to redirect_to(addresses_path)
      end

      it 'rebuild the full address with new attributes' do
        address.build_full_address
        old_full_address = address.full_address
        patch :update, params: { id: address.id, address: new_attrs }
        expect(address.reload.full_address).not_to eq(old_full_address)
      end
    end

    context 'with invalid params' do
      it 'renders edit template' do
        patch :update, params: { id: address.id, address: { recipient: '' } }
        expect(response).to be_success
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destory' do
    before { signin_as customer }
    context 'destroyable address' do
      it 'destorys the requested address' do
        address
        expect {
          delete :destroy, params: { id: address.id }
        }.to change(Address, :count).by(-1)
      end

      it 'redirects to address list' do
        address
        delete :destroy, params: { id: address.id }
        expect(response).to redirect_to(addresses_path)
        expect(flash[:success]).to be_present
      end
    end

    context 'undestroyable address' do
      it 'renders warning and returns to address list' do
        # TODO: REFACTOR ONCE ORDER MODEL IS AVAILABLE
        order_address = FactoryGirl.create(:address, addressable_type: 'Order')
        delete :destroy, params: { id: order_address.id }
        expect(flash[:warning]).to be_present
      end
    end
  end

end
