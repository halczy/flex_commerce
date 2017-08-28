require 'rails_helper'

RSpec.describe CartsController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:cart) { FactoryGirl.create(:cart) }

  describe 'POST add' do

    before do
      @product = FactoryGirl.create(:product)
      3.times { FactoryGirl.create(:inventory, product: @product) }
    end

    it 'adds product inventories and redirect to cart#show' do
      signin_as(customer)
      post :add, params: { pid: @product.id }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(cart_path)
      expect(assigns(:current_cart).inventories.count).to eq(1)
    end

    it 'adds product inventories and redirect to cart#show as guest' do
      post :add, params: { pid: @product.id }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(cart_path)
      expect(assigns(:current_cart).inventories.count).to eq(1)
    end

    it 'returns flash warning if product is requested stock is not available' do
      request.env['HTTP_REFERER'] = root_url
      post :add, params: { pid: @product.id, return_back: true, quantity: "10" }
      expect(flash[:warning]).to be_present
      expect(response).to redirect_to(root_url)
    end

    context 'set_product' do
      it 'redirect to home page if invalid product id is provided' do
        post :add, params: { pid: 'a20fj90j23' }
        expect(assigns(:product)).to be_nil
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(root_url)
      end

      it 'does not set quantity to zero when it is empty' do
        post :add, params: { pid: @product.id, quantity: "" }
        expect(flash[:success]).to be_present
        expect(Cart.last.inventories.count).to eq(1)
      end
    end
  end

  describe 'DELETE remove' do

    before do
      @product = FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart)
      3.times { FactoryGirl.create(:inventory, cart: @cart, product: @product,
                                               status: 1) }
      session[:cart_id] = @cart.id
    end

    it 'removes inventories by product' do
      delete :remove, params: { pid: @product.id, quantity: '0' }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(cart_path)
      expect(@cart.reload.inventories).to be_empty
    end

    it 'removes specified amount of inventories' do
      delete :remove, params: { pid: @product.id, quantity: '2' }
      expect(flash[:success]).to be_present
      expect(@cart.reload.inventories.count).to eq(1)
    end

    it 'redirects back to page that init the delete action' do
      request.env['HTTP_REFERER'] = root_url
      delete :remove, params: { pid: @product.id, return_back: true }
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET #show" do
    it "returns http success as guest" do
      get :show
      expect(response).to have_http_status(:success)
      expect(assigns(:current_cart).user).to be_nil
    end

    it 'returns http sucesss when logged in' do
      signin_as(customer)
      get :show
      expect(response).to have_http_status(:success)
      expect(assigns(:current_cart).user.id).to eq(customer.id)
    end
  end

end
