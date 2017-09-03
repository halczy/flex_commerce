require 'rails_helper'

RSpec.describe AddressesController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }

  before do
    FactoryGirl.create(:community)
  end

  describe 'GET new' do
    it 'response successfully' do
      signin_as(customer)
      get :new
      expect(response).to be_success
    end

    describe 'access control' do
      it 'redirects to sign in page if user is not signed in' do
        get :new
        expect(response).to redirect_to(signin_path)
      end
    end
  end


end
