require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:customer)    { FactoryGirl.create(:customer) }
  let(:cart)        { FactoryGirl.create(:cart) }
  let(:inventory)   { FactoryGirl.create(:inventory) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }
  let(:no_shipping) { FactoryGirl.create(:no_shipping) }

  let(:order)           { FactoryGirl.create(:order, user: customer) }

  let(:order_selected)  { FactoryGirl.create(:order, selected: true, user: customer) }
  let(:order_set)       { FactoryGirl.create(:order, set: true, user: customer) }
  let(:order_confirmed) { FactoryGirl.create(:order, confirmed: true, user: customer) }

  let(:order_pickup_selected)   { FactoryGirl.create(:order, selected: true,
                                                             only_pickup: true,
                                                             user: customer) }
  let(:order_pickup_set)        { FactoryGirl.create(:order, set: true,
                                                             only_pickup: true,
                                                             user: customer) }
  let(:order_delivery_selected) { FactoryGirl.create(:order, selected: true,
                                                             only_delivery: true,
                                                             user: customer) }
  let(:order_delivery_set)      { FactoryGirl.create(:order, set:true,
                                                             only_delivery: true,
                                                             user: customer) }
  let(:order_no_shipping_set)   { FactoryGirl.create(:order, set: true,
                                                             no_shipping: true,
                                                             user: customer) }

  before do |example|
    unless example.metadata[:skip_before]
      signin_as customer
    end
  end

  describe 'GET index' do
    before do
      @customer = customer
      @orders_in_creation = [order, order_selected, order_set, order_confirmed]
      @orders_in_creation.each { |o| o.update(user: @customer)}
      @orders_in_payment = []
      @orders_in_payment << FactoryGirl.create(:order, user: @customer, status: 30)
      @orders_in_payment << FactoryGirl.create(:order, user: @customer, status: 40)
      @orders_in_payment << FactoryGirl.create(:order, user: @customer, status: 50)
      @orders_in_service = []
      @orders_in_service << FactoryGirl.create(:order, user: @customer, status: 60)
      @orders_in_service << FactoryGirl.create(:order, user: @customer, status: 70)
      @orders_in_service << FactoryGirl.create(:order, user: @customer, status: 80)
      @orders_in_service << FactoryGirl.create(:order, user: @customer, status: 90)
      @orders_in_service << FactoryGirl.create(:order, user: @customer, status: 100)
    end

    context 'completed orders' do
      it 'returns completed orders without providing filter params' do
        get :index
        expect(response).to be_success
        expect(assigns(:orders).count).to eq(5)
        expect(assigns(:orders)).to match_array(@orders_in_service)
      end

      it 'returns completed orders when given orders_in_service filter' do
        get :index, params: { filter: 'service_process' }
        expect(assigns(:orders).count).to eq(5)
        expect(assigns(:orders)).to match_array(@orders_in_service)
      end
    end

    context 'pending payment' do
      it 'returns orders pending payments when given the' do
        get :index, params: { filter: 'payment_process' }
        expect(assigns(:orders).count).to eq(3)
        expect(assigns(:orders)).to match_array(@orders_in_payment)
      end
    end

    context 'incomplete orders' do
      it 'returns orders that are incomplete' do
        get :index, params: { filter: 'creation_process' }
        expect(assigns(:orders).count).to eq(4)
        expect(assigns(:orders)).to match_array(@orders_in_creation)
      end
    end
  end


  describe 'GET show' do
    it 'responses with order' do
      get :show, params: { id: order.id }
      expect(response).to be_success
      expect(assigns(:order)).to eq(order)
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
      get :shipping, params: { id: order.id }
      expect(response).to be_success
      expect(response).to render_template(:shipping)
    end

    context 'access control' do
      it 'only allows user to view their own order' do
        another_customer = FactoryGirl.create(:customer)
        signin_as another_customer
        get :shipping, params: { id: order.id }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'PATCH set_shipping' do
    before do
      product_1, product_2, product_3 = order.products
      @attrs = {
       '0' => { "shipping_methods" => delivery.id,    "id" => product_1.id },
       '1' => { "shipping_methods" => delivery.id,    "id" => product_2.id },
       '2' => { "shipping_methods" => self_pickup.id, "id" => product_3.id } }
      @ns_attr = {
       '0' => { "shipping_methods" => no_shipping.id, "id" => product_1.id },
       '1' => { "shipping_methods" => no_shipping.id, "id" => product_2.id },
       '2' => { "shipping_methods" => no_shipping.id, "id" => product_3.id } }
    end

    context 'with valid params' do
      it 'sets shipping and redirect to address page' do
        patch :set_shipping, params: { id: order.id,
                                       order: { products_attributes: @attrs } }
        expect(response).to redirect_to(address_order_path(order.id))
      end

      it 'sets shipping and redirect to review page if no shipping is selected' do
        patch :set_shipping, params: { id: order.id,
                                       order: { products_attributes: @ns_attr} }
        expect(response).to redirect_to(review_order_path(order.id))
      end
    end

    context 'with invalid params' do
      it 'redirects back to shipping select page if param is invalid' do
        patch :set_shipping, params: { id: order.id }
        expect(response).to redirect_to(shipping_order_path(order.id))
      end
    end
  end

  describe 'GET address' do
    it 'responses successfully' do
      get :address, params: { id: order_selected.id }
      expect(assigns(:self_pickups)).to be_present
      expect(assigns(:deliveries)).to be_present
      expect(assigns(:customer)).to eq(order_selected.user)
      expect(assigns(:address)).to be_present
      expect(response).to be_success
    end

    it 'responses successfully with pickup exclusive order' do
      get :address, params: { id: order_pickup_selected.id }
      expect(assigns(:self_pickups)).to be_present
      expect(assigns(:deliveries)).to be_empty
      expect(response).to be_success
    end

    it 'responses successfully with deliveries exclusive order' do
      get :address, params: { id: order_delivery_selected.id }
      expect(assigns(:self_pickups)).to be_empty
      expect(assigns(:deliveries)).to be_present
      expect(response).to be_success
    end
  end

  describe 'POST create_address' do
    context 'with valid params' do
      context 'create new address' do
        before do
          @valid_attrs = FactoryGirl.attributes_for(:address,
                                                    addressable: customer)
        end

        it 'creates address for order and user' do
          expect {
            post :create_address, params: { id: order_delivery_selected.id,
                                            address: @valid_attrs }
          }.to change(Address, :count).by(3)
          expect(customer.addresses).to be_present
          expect(controller.params[:address][:address_id]).to be_present
        end

        it 'redirects to payment action via set_address' do
          post :create_address, params: { id: order_delivery_selected.id,
                                          address: @valid_attrs }
          expect(response).to redirect_to(review_order_path)
          expect(order_delivery_selected.reload.status).to eq('shipping_confirmed')
        end
      end

      context 'select existing address' do
        before do
          @addr_id = FactoryGirl.create(:address, addressable: customer).id
        end

        it 'creates address for order' do
          expect {
            post :create_address, params: { id: order_delivery_selected.id,
                                            address: { address_id: @addr_id } }
          }.to change(Address, :count).by(2)
        end

        it 'redirects to payment action via set_address' do
          post :create_address, params: { id: order_delivery_selected.id,
                                          address: { address_id: @addr_id } }
          expect(response).to redirect_to(review_order_path)
          expect(order_delivery_selected.reload.status).to eq('shipping_confirmed')
        end
      end
    end

    context 'with invalid params' do
      it 'renders error messages' do
        post :create_address, params: { id: order_delivery_selected.id,
                                        address: { recipient: '' } }
        expect(response).to render_template(:address)
      end
    end
  end

  describe 'PATCH set_address' do
    it 'response successfully and confirms shipping' do
      patch :set_address, params: { id: order_pickup_selected.id }
      expect(response).to redirect_to(review_order_path)
      expect(order_pickup_selected.reload.status).to eq('shipping_confirmed')
    end
  end

  describe 'GET review' do
    it 'responses successfully' do
      get :review, params: { id: order_set.id }
      expect(response).to be_success
    end
  end

  describe 'PATCH confirm' do
    context 'with valid params' do
      it 'confirms order' do
        patch :confirm, params: { id: order_set.id }
        expect(order_set.reload.confirmed?).to be_truthy
      end

      it 'redirects to payment page' do
        patch :confirm, params: { id: order_set.id }
        expect(response).to redirect_to payment_order_path
      end
    end

    context 'with invalid params' do
      it 'redirects to reivew_order_path if order fails to confirm' do
        patch :confirm, params: { id: order.id }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(review_order_path)
      end
    end
  end

  describe 'POST create_wallet_payment' do
    it 'creates payment and charge customer wallet with full amount' do
      order_confirmed.user.wallet.update(balance: 999999)
      post :create_wallet_payment, params: { id: order_confirmed.id,
                                             amount: order_confirmed.total }
      payment = Payment.last
      expect(response).to redirect_to(success_order_path(payment_id: payment.id))
    end

    it 'creates payment and charge customer wallet with custom amount' do
      order_confirmed.user.wallet.update(balance: 999999)
      post :create_wallet_payment, params: { id: order_confirmed.id,
                                             amount: order_confirmed.total,
                                             custom_amount: 1 }
      payment = Payment.last
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(payment_order_path)
      expect(order_confirmed.reload.partial_payment?).to be_truthy
    end

    context 'invalid params' do
      it 'flashes error message if customer wallet balance is zero' do
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: order_confirmed.total }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error msg if amount is larger than order total' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: 999999 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error msg if custom_amount is larger than order total' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               custom_amount: 999999 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error message if amount is zero' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: 0 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error message if custom_amount is zero' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: order_confirmed.total,
                                               custom_amount: 0 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error message if amount is negative' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: -10 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error message if custom_amount is negative' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id,
                                               amount: order_confirmed.total,
                                               custom_amount: -100 }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end

      it 'flashes error message if no amount params are given' do
        order_confirmed.user.wallet.update(balance: 999999)
        post :create_wallet_payment, params: { id: order_confirmed.id }
        expect(flash[:warning]).to be_present
        expect(response).to redirect_to(payment_order_path)
      end
    end
  end

  describe 'GET resume' do
    it 'redirects to shipping action if order status is created' do
      get :resume, params: { id: order.id }
      expect(response).to redirect_to(shipping_order_path)
    end

    it 'redirects to reivew page if order status is shipping confirmed' do
      get :resume, params: { id: order_set.id }
      expect(response).to redirect_to(review_order_path)
    end

    it 'redirects to payment page if order status is comfirmed' do
      get :resume, params: { id: order_confirmed.id }
      expect(response).to redirect_to(payment_order_path)
    end
  end
end
