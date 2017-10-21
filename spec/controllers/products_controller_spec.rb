require 'rails_helper'

RSpec.describe ProductsController, type: :controller  do

  let(:product) { FactoryBot.create(:product) }

  describe "GET show" do
    it 'returns a success response' do
      get :show, params: { id: product.id }
      expect(response).to be_success
    end

    it 'returns a product instance' do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end
end
