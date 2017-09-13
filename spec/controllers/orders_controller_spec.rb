require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:customer)    { FactoryGirl.create(:customer) }
  let(:cart)        { FactoryGirl.create(:cart) }
  let(:inventory)   { FactoryGirl.create(:inventory) }
  let(:new_order)   { FactoryGirl.create(:new_order) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }

  let(:order_pickup_selected) { FactoryGirl.create(:order_pickup_selected) }
  let(:order_delivery_selected) { FactoryGirl.create(:order_delivery_selected) }
  let(:order_mix_selected) { FactoryGirl.create(:order_mix_selected) }

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
        expect(response).to redirect_to(shipping_order_path(Order.last))
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

  describe 'GET shipping' do
    it 'response successfully' do
      get :shipping, params: { id: new_order.id }
      expect(response).to be_success
      expect(response).to render_template(:shipping)
    end
  end

  describe 'PATCH set_shipping' do
    before do
      product_1, product_2, product_3 = new_order.products
      @attrs = {
       '0' => { "shipping_methods" => delivery.id, "id" => product_1.id },
       '1' => { "shipping_methods" => delivery.id, "id" => product_2.id },
       '2' => { "shipping_methods" => self_pickup, "id" => product_3.id } }
    end

    context 'with valid params' do
      it 'sets shipping and redirect to address page' do
        patch :set_shipping, params: { id: new_order.id,
                                       order: { products_attributes: @attrs } }
        expect(response).to redirect_to address_order_path(new_order.id)
      end
    end

    context 'with invalid params' do
      it 'redirects back to set shipping if param is invalid' do
        patch :set_shipping, params: { id: new_order.id }
        expect(response).to redirect_to set_shipping_order_path(new_order.id)
      end
    end
  end

  describe 'GET address' do
    it 'responses successfully' do
      get :address, params: { id: order_mix_selected.id }
      expect(assigns(:self_pickups)).to be_present
      expect(assigns(:deliveries)).to be_present
      expect(assigns(:customer)).to eq(order_mix_selected.user)
      expect(assigns(:address)).to be_present
    end
  end

end
