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
        product_params[:product][:description] = "<img src=\"/#{image.image.id}\">"
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


end
