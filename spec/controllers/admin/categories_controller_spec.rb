require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  describe 'GET index' do
    it 'responses successfully' do
      signin_as(admin)
      get :index
      expect(response).to render_template(:index)
    end

    context 'access control' do
      it 'does not allow non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET new' do
    it 'responses successfully' do
      signin_as(admin)
      get :new
      expect(response).to render_template(:new)
    end
  end

end
