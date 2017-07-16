require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do

  let(:product) { Product.create(:product) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'access control' do
      it 'does not allow non-admin' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
