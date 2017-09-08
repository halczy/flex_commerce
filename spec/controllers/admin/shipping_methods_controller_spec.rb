require 'rails_helper'

RSpec.describe Admin::ShippingMethodsController, type: :controller do

  let(:admin)       { FactoryGirl.create(:admin) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:no_shipping) { FactoryGirl.create(:no_shipping) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }

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
end
