require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  
  
  let(:customer) { FactoryGirl.create(:customer) }
  
  describe 'GET show' do
    it "returns a success response" do
      signin_as(customer)
      get :show, params: { id: customer.id }
      expect(response).to be_success
    end
    
    
    context 'access control' do
      it 'rejects guest access' do
        get :show, params: { id: customer.id }
        expect(response).to redirect_to signin_path
      end
      
      it "redirects customer that try to access another customer's profile" do
        customer_1 = FactoryGirl.create(:customer)
        customer_2 = FactoryGirl.create(:customer)
        signin_as(customer_1)
        get :show, params: { id: customer_2.id }
        expect(response).to redirect_to root_url
        expect(flash[:danger]).to be_present
      end
    end
  end
end