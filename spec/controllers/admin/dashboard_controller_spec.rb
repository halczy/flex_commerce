require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  describe 'GET index' do
    it 'renders the dashboard index' do
      signin_as(admin)
      get :index
      expect(response).to render_template(:index)
    end

    it 'contains header title' do
      signin_as(admin)
      get :index
      expect(assigns(:title)).to be_truthy
    end

    context 'access control' do
      it 'does not allow non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
