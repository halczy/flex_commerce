require 'rails_helper'

RSpec.describe CartsController, type: :controller do

  let(:customer) { FactoryBot.create(:customer) }
  let(:cart) { FactoryBot.create(:cart) }

  describe 'POST add' do
    before do
      @product = FactoryBot.create(:product)
      3.times { FactoryBot.create(:inventory, product: @product) }
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

    context 'validate_product' do
      it "does not add disabled product to cart" do
        @product.disabled!
        post :add, params: { pid: @product.id }
        expect(flash[:danger]).to be_present
      end

      it "redirects to root_url when attempt to add disabled product" do
        @product.disabled!
        post :add, params: { pid: @product.id }
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'DELETE remove' do
    before do
      @product = FactoryBot.create(:product)
      @cart = FactoryBot.create(:cart)
      3.times { FactoryBot.create(:inventory, cart: @cart, product: @product,
                                               status: 1) }
      session[:cart_id] = @cart.id
    end

    it 'removes inventories by product' do
      delete :remove, params: { pid: @product.id }
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

  describe 'PATCH update' do
    before do
      @product = FactoryBot.create(:product, strict_inventory: false)
      @cart = FactoryBot.create(:cart)
      5.times { FactoryBot.create(:inventory, cart: @cart, product: @product,
                                               status: 1) }
      session[:cart_id] = @cart.id
    end

    it 'redirects action to GET add with diff quantity' do
      patch :update, params: { pid: @product.id, quantity: "7" }
      expect(flash[:success]).to be_present
      expect(@cart.inventories.reload.count).to eq(7)
    end

    it 'redirects action to DELETE remove with diff quantity' do
      patch :update, params: { pid: @product.id, quantity: "2" }
      expect(flash[:success]).to be_present
      expect(@cart.inventories.reload.count).to eq(2)
    end

    it 'redirects back to the path that init. the request' do
      request.env['HTTP_REFERER'] = root_url
      patch :update, params: { pid: @product.id, quantity: "3", return_back: true }
      expect(@cart.inventories.reload.count).to eq(3)
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
