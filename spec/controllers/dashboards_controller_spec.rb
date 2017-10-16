require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }

  describe 'GET show' do
    before { signin_as(customer) }

    it "returns a success response" do
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'populates orders in creation process' do
      FactoryGirl.create(:order, user: customer)
      FactoryGirl.create(:order, user: customer, confirmed: true)
      get :show, params: { id: customer.id }
      expect(assigns(:creation_process_orders).count).to eq(2)
    end

    it 'populates orders in payment process' do
      FactoryGirl.create(:payment_order, user: customer)
      FactoryGirl.create(:payment_order, user: customer, partial: true)
      FactoryGirl.create(:payment_order, user: customer, fail: true)
      get :show, params: { id: customer.id }
      expect(assigns(:payment_process_orders).count).to eq(3)
    end

    it 'populates orders in shipment process' do
      FactoryGirl.create(:service_order, user: customer)
      FactoryGirl.create(:service_order, user: customer, pickup_pending: true)
      FactoryGirl.create(:service_order, user: customer, shipped: true)
      get :show, params: { id: customer.id }
      expect(assigns(:shipment_orders).count).to eq(3)
    end
  end

  describe 'access control' do
    it 'rejects guest access' do
      get :show, params: { id: customer.id }
      expect(response).to redirect_to signin_path
    end

    it "redirects customer that try to access another customer's profile" do
      customer_1 = FactoryGirl.create(:customer)
      customer_2 = FactoryGirl.create(:customer)
      signin_as(customer_1)
      get :show, params: { id: customer_2.id }
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to be_present
    end
  end
end
