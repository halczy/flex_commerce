require 'rails_helper'

RSpec.describe Admin::CustomersController, type: :controller do

  let(:admin)    { FactoryBot.create(:admin) }
  let(:customer) { FactoryBot.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end
  end

  describe 'GET search' do
    before do
      @c1 = FactoryBot.create(:customer, name: 'John Doe')
    end

    it 'responses successfully with search result' do
      get :search, params: { search_term: 'DOE' }
      expect(response).to render_template(:search)
      expect(assigns(:search_result).count).to eq(1)
    end

    it 'responses successfully with empty search result' do
      get :search, params: { search_term: 'this_customer_should_not_exist'}
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
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'sets requested customer' do
      get :show, params: { id: customer.id }
      expect(assigns(:customer)).to eq(customer)
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id: customer.id }
      expect(response).to be_success
    end

    it 'renders edit template' do
      get :edit, params: { id: customer.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    it 'updates with valid params' do
      patch :update, params: { id: customer.id, customer: {name: 'UPDATED NAME'} }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_customer_path(customer))
      expect(assigns(:customer).name).to eq('UPDATED NAME')
    end

    it 'renders error messages with invalid params' do
      patch :update, params: { id: customer.id, customer: { cell_number: 110 } }
      expect(response).to render_template(:edit)
    end
  end
end
