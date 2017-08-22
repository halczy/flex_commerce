require 'rails_helper'

RSpec.describe Admin::InventoriesController, type: :controller do

  let(:admin)     { FactoryGirl.create(:admin) }
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:product)   { FactoryGirl.create(:product) }

  before { signin_as admin }

  xdescribe 'GET products_view' do

    before do
      @product_1 = FactoryGirl.create(:product)
      @product_2 = FactoryGirl.create(:product)
      3.times { FactoryGirl.create(:inventory, product: @product_1) }
      2.times { FactoryGirl.create(:inventory, product: @product_2, status: 2) }
      2.times { FactoryGirl.create(:inventory, product: @product_2, status: 3) }
    end

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
      get :products_view, params: { inv_status: "in_stock" }

      products = assigns(:products)
      expect(products).to match_array([@product_1])
    end

    it "returns a list of products that are out of stock" do
      get :products_view, params: { inv_status: "out_of_stock" }

      products = assigns(:products)
      expect(products).to match_array([@product_2])
    end
  end

end
