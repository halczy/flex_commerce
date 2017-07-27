require 'rails_helper'

RSpec.describe Admin::ImagesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:image) { FactoryGirl.create(:image) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

end
