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
end
