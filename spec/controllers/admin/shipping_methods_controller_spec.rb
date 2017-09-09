require 'rails_helper'

RSpec.describe Admin::ShippingMethodsController, type: :controller do

  let(:admin)       { FactoryGirl.create(:admin) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:no_shipping) { FactoryGirl.create(:no_shipping) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }
  let(:province)    { FactoryGirl.create(:province) }

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
      FactoryGirl.create(:province)
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
        expect(response).to redirect_to(admin_shipping_methods_path)
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
        expect(response).to redirect_to(admin_shipping_methods_path)
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
            addresses_attributes: {
              '0': {
                province_state: province.id, street: 'some street',
                recipient: 'Admin', contact_number: '1234567890'
              }
            }
          }
        }
        expect(ShippingMethod.count).to eq(1)
        expect(Address.count).to eq(0)
        expect(response).to redirect_to(admin_shipping_methods_path)
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
            addresses_attributes: {
              '0': {
                province_state: province.id, street: 'some street',
                recipient: 'Admin', contact_number: '1234567890'
              }
            }
          }
        }

        expect(ShippingMethod.count).to eq(1)
        expect(ShippingRate.count).to eq(1)
        expect(Address.count).to eq(1)
        addr = ShippingMethod.first.addresses.first
        expect(addr.province_state).to eq(province.id)
        expect(addr.street).to eq('some street')
        expect(addr.full_address).to be_present
        expect(response).to redirect_to(admin_shipping_methods_path)
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
      @shipping_method = FactoryGirl.create(:delivery)
      FactoryGirl.create(:shipping_rate, geo_code: province.id,
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
      FactoryGirl.create(:address, addressable: @shipping_method)
      get :show, params: { id: @shipping_method.id }
      expect(assigns(:address)).to be_present
    end
  end

  describe 'GET edit' do
    before do
      @shipping_method = FactoryGirl.create(:self_pickup)
      FactoryGirl.create(:shipping_rate, shipping_method: @shipping_method)
      FactoryGirl.create(:address, addressable: @shipping_method)
    end

    it 'response successfully' do
      get :edit, params: { id: @shipping_method.id }
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end
end
