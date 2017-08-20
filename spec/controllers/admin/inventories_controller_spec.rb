require 'rails_helper'

RSpec.describe Admin::InventoriesController, type: :controller do

  let(:inventory) { FactoryGirl.create(:inventory) }

  describe 'GET index' do
    it 'response successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end

    it 'returns a list of products with inventory info'
  end

end
