require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do

  let(:admin)                   { FactoryBot.create(:admin) }
  let(:order)                   { FactoryBot.create(:order) }
  let(:order_selected)          { FactoryBot.create(:order, selected: true) }
  let(:order_set)               { FactoryBot.create(:order, set: true) }
  let(:order_confirmed)         { FactoryBot.create(:order, confirmed: true) }
  let(:payment_order)           { FactoryBot.create(:payment_order) }
  let(:payment_success_order)   { FactoryBot.create(:payment_order, success: true) }
  let(:service_order)           { FactoryBot.create(:service_order) }
  let(:service_order_ppending)  { FactoryBot.create(:service_order, pickup_pending: true) }
  let(:service_order_shipped)   { FactoryBot.create(:service_order, shipped: true) }
  let(:completed_order)         { FactoryBot.create(:service_order, completed: true) }

  before { signin_as admin }

  describe 'GET index' do
    before do
      @order = order
      @order_selected = order_selected
      @order_set = order_set
      @order_confirmed = order_confirmed
    end

    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end

    it 'responses with orders matching created status' do
      get :index, params: { status: 'created' }
      expect(assigns(:orders)).to match_array([@order, @order_selected])
    end

    it 'responses with orders matching shipping_confirmed status' do
      get :index, params: { status: 'shipping_confirmed' }
      expect(assigns(:orders)).to match_array([@order_set])
    end

    it 'responses with orders matching confirmed status' do
      get :index, params: { status: 'confirmed' }
      expect(assigns(:orders)).to match_array([@order_confirmed])
    end
  end

  describe 'GET search' do
    before do
      @customer = FactoryBot.create(:customer, name: 'TEST 1')
      @order = FactoryBot.create(:order, user: @customer)
    end

    it 'responses successfully with search result' do
      get :search, params: { search_term: @customer.id }
      expect(response).to render_template(:search)
      expect(assigns(:search_result)).to match_array([@order])
    end

    it 'responses successfully with empty search result' do
      get :search, params: { search_term: 'this_order_should_not_exist'}
      expect(assigns(:search_result).count).to eq(0)
    end

    it 'renders flash message when no search term is provided' do
      get :search, params: { }
      expect(response).to render_template(:search)
      expect(flash[:warning]).to be_present
      expect(assigns(:search_result)).to be_nil
    end
  end

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: order.id }
      expect(response).to be_success
      expect(assigns(:order)).to be_an_instance_of Order
    end
  end

  describe 'PATCH confirm' do
    it 'confirms order with correct status' do
      patch :confirm, params: { id: payment_success_order }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_order_path(payment_success_order))
    end

    it 'flashes error message if fail to confirm' do
      patch :confirm, params: { id: payment_order }
      expect(flash[:danger]).to be_present
    end
  end

  describe 'PATCH set_pickup_ready' do
    it 'sets order status to pickup pending' do
      patch :set_pickup_ready, params: { id: payment_success_order }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_order_path(payment_success_order))
    end

    it 'flashes error message if fail to set order as pickup ready ' do
      allow_any_instance_of(OrderService).to receive(:set_pickup_ready)
                                             .and_return(false)
      patch :set_pickup_ready, params: { id: payment_order }
      expect(flash[:danger]).to be_present
    end
  end

  describe 'POST add_tracking' do
    it 'passes params to add_tracking service and flash success message' do
      post :add_tracking, params: { id: service_order, tracking_number: '12346',
                                                       shipping_company: 'ABC' }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_order_path(service_order))
    end

    it 'fills shipping_company param with pre_select_shipco params if empty' do
      post :add_tracking, params: { id: service_order, tracking_number: '123456',
                                                       pre_select_shipco: 'ABC',
                                                       shipping_company: '' }
      expect(flash[:success]).to be_present
        expect(assigns(:order).reload.shipment['shipping_company']).to eq('ABC')
    end

    it 'flashes error message if params is not saved' do
      allow_any_instance_of(OrderService).to receive(:add_tracking)
                                             .and_return(false)
      post :add_tracking, params: { id: payment_order, tracking_number: '123',
                                                       shipping_company: 'ABC' }
      expect(flash[:danger]).to be_present
    end

    it 'flashes warning message when empty param is provided' do
      post :add_tracking, params: { id: service_order }
      expect(flash[:warning]).to be_present
    end
  end

  describe 'PATCH complete_pickup' do
    it 'calls complete_pickup order service' do
      service_order_ppending.shipment[:shipping_completed_at] = DateTime.now
      service_order_ppending.save
      patch :complete_pickup, params: { id: service_order_ppending }

      expect(assigns(:order).reload.completed?).to be_truthy
      expect(assigns(:order).reload.shipment['pickup_completed_at']).to be_present
    end

    it 'redirects to order show action with flash message' do
      patch :complete_pickup, params: { id: service_order_ppending }

      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_order_path(service_order_ppending))
    end
  end

  describe 'PATCH complete_shipping' do
    it 'calls complete_shipping order service' do
      patch :complete_shipping, params: { id: service_order_shipped }

      expect(assigns(:order).reload.shipment['shipping_completed_at']).to be_present
      expect(assigns(:order).reload.shipped?).to be_truthy
    end

    it 'redirects to order show action with flash message' do
      patch :complete_shipping, params: { id: service_order_shipped }

      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_order_path(service_order_shipped))
    end
  end
end
