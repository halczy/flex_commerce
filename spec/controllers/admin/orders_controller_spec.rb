require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do

  let(:admin)           { FactoryGirl.create(:admin) }
  let(:order)           { FactoryGirl.create(:order) }
  let(:order_selected)  { FactoryGirl.create(:order, selected: true) }
  let(:order_set)       { FactoryGirl.create(:order, set: true) }
  let(:order_confirmed) { FactoryGirl.create(:order, confirmed: true) }

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
      @customer = FactoryGirl.create(:customer, name: 'TEST 1')
      @order = FactoryGirl.create(:order, user: @customer)
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
end
