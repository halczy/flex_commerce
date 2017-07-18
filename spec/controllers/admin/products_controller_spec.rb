require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do

  let(:product) { FactoryGirl.create(:product) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'products a list of products' do
      product_1 = product
      product_2 = product
      get :index
      expect(assigns(:products).count).to be_present
    end

    context 'access control' do
      it 'does not allow non-admin' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET new' do
    it 'responses successfully' do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:product)).to be_a_new(Product)
    end
  end

  describe 'POST create' do

  end


end
