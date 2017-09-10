require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:customer)  { FactoryGirl.create(:customer) }
  let(:cart)      { FactoryGirl.create(:cart) }
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:new_order) { FactoryGirl.create(:new_order) }

  before do |example|
    unless example.metadata[:skip_before]
      signin_as customer
    end
  end

  describe 'POST create' do
    context 'with valid attributes' do
      before do
        @cart = FactoryGirl.create(:cart, user: customer)
        3.times { @cart.inventories << FactoryGirl.create(:inventory, cart: @cart) }
      end

      it 'creates order and redirect to select shipping' do
        expect {
          post :create, params: { cart_id: @cart.id }
        }.to change(Order, :count).by(1)
        expect(response).to redirect_to(select_shipping_order_path(Order.last))
      end
    end

    context 'with invalid attributes' do
      it 'flash error when cart is empty' do
        empty_cart = FactoryGirl.create(:cart, user: customer)
        post :create, params: { cart_id: empty_cart.id }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(cart_path)
      end

      it 'redirect_to to sign in if not logged in', skip_before: true do
        3.times { cart.inventories << FactoryGirl.create(:inventory, cart: cart) }
        post :create, params: { cart_id: cart.id }
        expect(response).to redirect_to(signin_path)
      end

      it 'redirect_to to cart_path if no params is cart_id provided' do
        post :create, params: { }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(cart_path)
      end
    end
  end

  describe 'GET select_shipping' do
    it 'response successfully' do
      get :select_shipping, params: { id: new_order.id }
      expect(response).to be_success
      expect(response).to render_template(:select_shipping)
    end
  end

end
