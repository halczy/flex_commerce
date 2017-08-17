require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  
  let(:category) { FactoryGirl.create(:category) }
  let(:product)  { FactoryGirl.create(:product)  }
  
  describe 'GET show' do
    it "returns a success response" do
      get :show, params: { id: category.id }
      expect(response).to be_success
    end
    
    it "returns category instance" do
      get :show, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
    
    it "returns associated products" do
      Categorization.create(category: category, product: product)
      get :show, params: { id: category.id }
      expect(assigns(:products)).to match_array([product])
    end
  end
  
  describe 'GET search' do
    before do
      @product_1 = FactoryGirl.create(:product, name: 'Red Sun')
      @product_2 = FactoryGirl.create(:product, name: 'Blue Sun')
      @product_3 = FactoryGirl.create(:product, name: 'Green Sun')
      @category = FactoryGirl.create(:category)
      Categorization.create(category: @category, product: @product_1)
      Categorization.create(category: @category, product: @product_2)
    end
    
    context 'full products quick search' do    
      it "responses with search result" do
        get :search, params: { search_term: 'sun' }
        expect(response).to render_template(:search)
        expect(assigns(:search_result)).to match_array([@product_1, @product_2, @product_3])
      end
      
      it "responses with empty search result " do
        get :search, params: { search_term: 'ABCDEFGAOOEKKCIE' }
        expect(response).to render_template(:search)
        expect(assigns(:search_result)).to match_array([])
      end
      
      it "renders flash message when no search term is provided" do
        get :search, params: { }
        expect(response).to render_template(:search)
        expect(flash[:warning]).to be_present
      end
    end
    
    context 'current category product search' do
      it "responses with search result" do
        
      end
      
      it "responses with empty search result " do
        
      end
      
      it "renders flash message when no search term is provided" do
      end
    end
  end
end