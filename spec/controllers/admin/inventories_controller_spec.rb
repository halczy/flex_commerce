require 'rails_helper'

RSpec.describe Admin::InventoriesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:inventory) { FactoryGirl.create(:inventory) }

  before { signin_as admin }

  describe 'GET index' do
    it 'response successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end

    it 'returns a list of products with inventory info' do
      FactoryGirl.create(:inventory)
      get :index
      product_1 = assigns(:products).first
      expect(product_1).to be_an_instance_of(Product)
      expect(product_1.inventories.first).to be_an_instance_of(Inventory)
    end
  end

end
