require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do

  let(:product)  { FactoryGirl.create(:product) }
  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }
  let(:image)    { FactoryGirl.create(:image) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'products a list of products' do
      5.times { FactoryGirl.create(:product) }
      get :index
      expect(assigns(:products).count).to eq(5)
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
    product_params = { product: { name: 'Name',
                                 tag_line: 'Tag Line',
                                 sku: 'SKU',
                                 introduction: 'Introduction',
                                 description: 'Description',
                                 specification: 'Specification',
                                 digital: false,
                                 strict_inventory: false,
                                 price_market: 12.35,
                                 price_member: 12.34,
                                 price_reward: 12.33,
                                 cost: 10 } }

    context 'with valid params' do
      it 'creates product' do
        post :create, params: product_params
        expect(response).to redirect_to admin_product_path(assigns(:product))
        expect(flash[:success]).to be_present
      end

      it 'associates image uploaded through trix editor' do
        product_params[:product][:description] = "<img src=\"/#{image.image[:fit].data['id']}\">"
        post :create, params: product_params
        expect(assigns(:product).images).to match_array([image])
      end
    end

    context 'with invalid params' do
      it 'renders new tempalte' do
        post :create, params: { product: { sku: 'sku' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end

  describe 'GET edit' do
    it 'returns a success response' do
      get :edit, params: { id: product.id }
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    context 'with valid params' do
      it 'updates the requested product' do
        patch :update, params: { id: product.id, product: { name: 'New Name'} }
        product.reload
        expect(product.name).to eq('New Name')
      end

      it 'redirects to the product' do
        patch :update, params: { id: product.id, product: { tag_line: 'New Tag'} }
        expect(response).to redirect_to admin_product_path(product)
      end
    end

    context 'with invalid params' do
      it 'renders edit page' do
        patch :update, params: { id: product.id, product: { name: ''} }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do
    before { @product = product }

    it 'destroys the requested product' do
      expect{
        delete :destroy, params: { id: @product.id }
      }.to change(Product, :count).by(-1)
    end

    it "redirects to the product list" do
      delete :destroy, params: { id: @product.id }
      expect(response).to redirect_to(admin_products_path)
    end
  end

  describe 'GET search' do
    before do
      @product_blue = FactoryGirl.create(:product, name: 'Blue Book')
      @product_red  = FactoryGirl.create(:product, name: 'Red Book')
    end

    it 'responses successfully with search result' do
      get :search, params: { search_term: 'RED' }
      expect(response).to render_template(:search)
      expect(assigns(:search_result).count).to eq(1)
    end

    it 'responses successfully with empty search result' do
      get :search, params: { search_term: 'this_product_should_not_exist'}
      expect(assigns(:search_result).count).to eq(0)
    end

    it 'renders flash message when no search term is provided' do
      get :search, params: { }
      expect(response).to render_template(:search)
      expect(flash[:warning]).to be_present
      expect(assigns(:search_result)).to be_nil
    end
  end


end
