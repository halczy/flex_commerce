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
end