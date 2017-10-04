require 'rails_helper'

RSpec.describe Admin::CustomersController, type: :controller do

  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

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
      @c1 = FactoryGirl.create(:customer, name: 'John Doe')
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
  end
end
