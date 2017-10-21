require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do

  let(:customer) { FactoryBot.create(:customer) }

  describe 'GET show' do
    before { signin_as(customer) }

    it "returns a success response" do
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'populates orders in creation process' do
      FactoryBot.create(:order, user: customer)
      FactoryBot.create(:order, user: customer, confirmed: true)
      get :show, params: { id: customer.id }
      expect(assigns(:creation_process_orders).count).to eq(2)
    end

    it 'populates orders in payment process' do
      FactoryBot.create(:payment_order, user: customer)
      FactoryBot.create(:payment_order, user: customer, partial: true)
      FactoryBot.create(:payment_order, user: customer, fail: true)
      get :show, params: { id: customer.id }
      expect(assigns(:payment_process_orders).count).to eq(3)
    end

    it 'populates orders in shipment process' do
      FactoryBot.create(:service_order, user: customer)
      FactoryBot.create(:service_order, user: customer, pickup_pending: true)
      FactoryBot.create(:service_order, user: customer, shipped: true)
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
      customer_1 = FactoryBot.create(:customer)
      customer_2 = FactoryBot.create(:customer)
      signin_as(customer_1)
      get :show, params: { id: customer_2.id }
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to be_present
    end
  end
end
