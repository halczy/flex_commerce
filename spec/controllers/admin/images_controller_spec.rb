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

  describe 'GET show' do
    it 'returns a success response with an image instance' do
      get :show, params: { id: image.id }
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(assigns(:image)).to eq(image)
      expect(assigns(:image_data)).not_to be_empty
    end
  end

end
