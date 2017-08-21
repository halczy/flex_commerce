require 'rails_helper'

RSpec.describe Admin::InventoriesController, type: :controller do

  let(:admin)     { FactoryGirl.create(:admin) }
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:product)   { FactoryGirl.create(:product) }

  before { signin_as admin }

  describe 'GET products_view' do
    it 'response successfully' do
      get :products_view
      expect(response).to render_template(:products_view)
      expect(response).to be_success
    end

    it 'returns all products' do
      FactoryGirl.create(:inventory)
      get :products_view
      
      product_1 = assigns(:products).first
      expect(product_1).to be_an_instance_of(Product)
      expect(product_1.inventories.first).to be_an_instance_of(Inventory)
    end
    
    it "returns a list of products that are in stock" do
      3.times { FactoryGirl.create(:inventory, product: product) }
      get :products_view, params: { in_stock: 1 }
      
      products = assigns(:products)
      expect(products).to be_present
      expect(products.first.inventories.count).to eq(3)
    end
    
    it "returns a list of products that are out of stock" do
      3.times { FactoryGirl.create(:inventory, product: product, status: 1) }
      2.times { FactoryGirl.create(:inventory, product: product, status: 1) }
      get :products_view, params: { out_of_stock: 1 }
      
      products = assigns(:products)
      expect(products).to be_present
      expect(products.first.inventories.count).to eq(5)
    end
  end

end
