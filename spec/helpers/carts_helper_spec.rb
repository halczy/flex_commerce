require 'rails_helper'

RSpec.describe CartsHelper, type: :helper do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:cart) { FactoryGirl.create(:cart) }

  describe '#current_cart' do
    it 'returns cart when user is logged in' do
      signin_as(customer)
      user_cart = FactoryGirl.create(:cart, user: customer)
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

  describe '#temp' do
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

end
