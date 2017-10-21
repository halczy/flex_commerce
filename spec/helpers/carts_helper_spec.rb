require 'rails_helper'

RSpec.describe CartsHelper, type: :helper do

  let(:customer) { FactoryBot.create(:customer) }
  let(:cart) { FactoryBot.create(:cart) }

  describe '#current_cart' do
    it 'returns cart when user is logged in' do
      signin_as(customer)
      user_cart = FactoryBot.create(:cart, user: customer)
      expect(helper.current_cart).to eq(user_cart)
    end

    it 'returns new cart when guest does not have a cart' do
      signin_as(customer)
      expect(helper.current_cart).to be_an_instance_of(Cart)
    end

    it 'returns cart when guest has cart_id in session' do
      session[:cart_id] = cart.id
      expect(helper.current_cart).to eq(cart)
    end

    it 'returns new cart and sets cart_id in session' do
      expect(helper.current_cart).to be_an_instance_of(Cart)
      expect(session[:cart_id]).to be_present
    end

    it 'returns new cart and reset session cart_id if previous cart was deleted' do
      session[:cart_id] = 99999999
      expect(helper.current_cart).to be_an_instance_of(Cart)
      expect(session[:cart_id]).not_to eq(99999999)
    end
  end

  describe '#find_or_create_session_cart' do
    it 'create a new cart if there is no cart session' do
      expect(helper.find_or_create_session_cart).to be_an_instance_of(Cart)
    end

    it 'returns existing cart if these is cart session' do
      session[:cart_id] = cart.id
      expect(helper.find_or_create_session_cart).to eq(cart)
    end

    it 'returns a new cart if cart session is of non-exsiting cart' do
      session[:cart_id] = 55588154545454
      new_cart = helper.find_or_create_session_cart
      expect(new_cart).to be_an_instance_of(Cart)
      expect(new_cart.id).not_to eq(55588154545454)
      expect(session[:cart_id]).to eq(new_cart.id)
    end
  end

  describe '#organize_cart' do
    it 'does not run if session cart_id is not present' do
      FactoryBot.create(:cart, user: customer)
      helper.organize_cart(customer)
      expect(customer.cart).not_to be_changed
    end

    it 'runs cart migration is valid session cart id is present' do
      session[:cart_id] = cart.id
      FactoryBot.create(:inventory, cart: cart)
      expect(organize_cart(customer)).to be_truthy
      expect(customer.cart.inventories.count).to eq(1)
    end

    it 'cleans up session cart id' do
      session[:cart_id] = cart.id
      organize_cart(customer)
      expect(session[:cart_id]).to be_nil
    end

    it 'destroy the session cart' do
      session[:cart_id] = cart.id
      expect(organize_cart(customer)).to be_truthy
      expect{ cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
