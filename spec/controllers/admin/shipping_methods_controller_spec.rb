require 'rails_helper'

RSpec.describe Admin::ShippingMethodsController, type: :controller do

  let(:admin)       { FactoryBot.create(:admin) }
  let(:delivery)    { FactoryBot.create(:delivery) }
  let(:no_shipping) { FactoryBot.create(:no_shipping) }
  let(:self_pickup) { FactoryBot.create(:self_pickup) }
  let(:province)    { FactoryBot.create(:province) }
  let(:product)     { FactoryBot.create(:product) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end

    it 'returns shipping methods' do
      delivery; no_shipping; self_pickup
      get :index
      expect(assigns(:shipping_methods).count).to eq(3)
    end
  end

  describe 'GET new' do
    it 'response successfully' do
      FactoryBot.create(:province)
      get :new
      expect(response).to be_success
      expect(assigns(:shipping_method)).to be_an_instance_of(ShippingMethod)
      expect(assigns(:provinces)).not_to be_empty
    end
  end

  describe 'POST create' do
    context 'with valid attributes' do
      it 'creates a no shipping method' do
        valid_attrs = { name: 'No Shipping', variety: 'no_shipping' }

        expect {
          post :create, params: { shipping_method: valid_attrs }
        }.to change(ShippingMethod, :count).by(1)
        expect(ShippingMethod.last.variety).to eq('no_shipping')
        expect(ShippingMethod.last.name).to eq('No Shipping')
        expect(response).
          to redirect_to(admin_shipping_method_path(ShippingMethod.last))
      end

      it 'creates a delivery shipping method' do
        post :create, params: {
          shipping_method: {
            name: 'Test', variety: 'delivery',
            shipping_rates_attributes: {
              "0": {
                geo_code: '*', init_rate: '20.00', add_on_rate: '10.00'
              }
            }
          }
        }

        expect(ShippingMethod.all.count).to eq(1)
        expect(ShippingRate.all.count).to eq(1)
        rate =  ShippingRate.first
        expect(rate.geo_code).to eq('*')
        expect(rate.init_rate_cents).to eq(2000)
        expect(rate.add_on_rate_cents).to eq(1000)
        expect(response).
          to redirect_to(admin_shipping_method_path(ShippingMethod.last))
      end

      it 'drops self pickup params if variety is delivery' do
        post :create, params: {
          shipping_method: {
            name: 'Test', variety: 'delivery',
            shipping_rates_attributes: {
              '0': {
                geo_code: province.id, init_rate: '1.00', add_on_rate: '0'
              }
            },
            address_attributes: {
              '0': {
                province_state: province.id, street: 'some street',
                recipient: 'Admin', contact_number: '1234567890'
              }
            }
          }
        }
        expect(ShippingMethod.count).to eq(1)
        expect(Address.count).to eq(0)
        expect(response).
          to redirect_to(admin_shipping_method_path(ShippingMethod.last))
      end

      it 'creates a self pickup method' do
        post :create, params: {
          shipping_method: {
            name: 'Test', variety: 'self_pickup',
            shipping_rates_attributes: {
              '0': {
                geo_code: '*', init_rate: '1.00', add_on_rate: '0'
              }
            },
            address_attributes: {
              province_state: province.id, street: 'some street',
              recipient: 'Admin', contact_number: '1234567890'
            }
          }
        }

        expect(ShippingMethod.count).to eq(1)
        expect(ShippingRate.count).to eq(1)
        expect(Address.count).to eq(1)
        addr = ShippingMethod.first.address
        expect(addr.province_state).to eq(province.id)
        expect(addr.street).to eq('some street')
        expect(addr.full_address).to be_present
        expect(response).
          to redirect_to(admin_shipping_method_path(ShippingMethod.last))
      end
    end

    context 'with invalid attributes' do
      it 'cannot be created without a name' do
        post :create, params: { shipping_method: {name: '', variety: 'no_shipping'} }
        expect(response).to render_template(:new)
      end

      it 'cannot be created without geo_code' do
        post :create, params: {
          shipping_method: {
            name: 'Test', variety: 'delivery',
            shipping_rates_attributes: {
              "0": {
                geo_code: '', init_rate: '20.00', add_on_rate: '10.00'
              }
            }
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET show' do
    before do
      @shipping_method = FactoryBot.create(:delivery)
      FactoryBot.create(:shipping_rate, geo_code: province.id,
                                         init_rate: 10,
                                         add_on_rate: 2,
                                         shipping_method: @shipping_method)
    end

    it 'response successfully' do
      get :show, params: { id: @shipping_method.id }
      expect(response).to be_success
      expect(response).to render_template(:show)
    end

    it 'has shipping rates instance' do
      get :show, params: { id: @shipping_method.id }
      expect(assigns(:shipping_rates)).to be_present
    end

    it 'has address instance' do
      FactoryBot.create(:address, addressable: @shipping_method)
      get :show, params: { id: @shipping_method.id }
      expect(assigns(:address)).to be_present
    end
  end

  describe 'GET edit' do
    before { @shipping_method = FactoryBot.create(:self_pickup) }

    it 'response successfully' do
      get :edit, params: { id: @shipping_method.id }
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    before do
      @shipping_method = FactoryBot.create(:self_pickup)
    end

    context 'with valid params' do
      it 'updates the requested shipping method' do
        patch :update, params: {
          id: @shipping_method.id,
          shipping_method: { name: 'New Name', variety: @shipping_method.variety } }
        expect(response).
          to redirect_to(admin_shipping_method_path(ShippingMethod.last))
        expect(@shipping_method.reload.name).to eq('New Name')
        expect(@shipping_method.shipping_rates.count).to eq(1)
        expect(@shipping_method.address).to be_present
      end

      # Nested attributes update are tested in shipping method feature spec
    end

    context 'with invalid params' do
      it 'renders edit template when name is removed' do
        patch :update, params: {
          id: @shipping_method.id,
          shipping_method: { name: '', variety: @shipping_method.variety } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do

    context 'destroyable' do
      before { @shipping_method = FactoryBot.create(:self_pickup) }
      it 'can be destroy' do
        expect {
          delete :destroy, params: { id: @shipping_method.id }
        }.to change(ShippingMethod, :count).by(-1)
      end

      it 'redirects to shipping method index with success flash message' do
        delete :destroy, params: { id: @shipping_method.id }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_shipping_methods_path)
      end

      it 'removes associated shipping rates' do
        expect {
          delete :destroy, params: { id: @shipping_method.id }
        }.to change(ShippingRate, :count).by(-1)
      end

      it 'removes associated address' do
        expect {
          delete :destroy, params: { id: @shipping_method.id }
        }.to change(Address, :count).by(-1)
      end
    end

    context 'undestroyable' do
      it 'does not destroy shipping method referred by product' do
        delivery.products << product
        expect {
          delete :destroy, params: { id: delivery }
        }.not_to change(ShippingMethod, :count)
      end

      it 'does not destroy shipping method referred by inventory' do
        FactoryBot.create(:inventory, shipping_method: self_pickup)
        expect {
          delete :destroy, params: { id: self_pickup }
        }.not_to change(ShippingMethod, :count)
      end

      it 'redirects to shipping method index with danger flash message' do
        delivery.products << product
        delete :destroy, params: { id: delivery }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(admin_shipping_methods_path)
      end
    end
  end
end
