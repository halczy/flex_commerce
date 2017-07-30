require 'rails_helper'

RSpec.describe Admin::ImagesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:image) { FactoryGirl.create(:image) }

  before { signin_as(admin) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'returns a success response with an image instance' do
      get :show, params: { id: image.id }
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(assigns(:image)).to eq(image)
      expect(assigns(:image_data)).not_to be_empty
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the image' do
      img_to_rm = image
      expect {
        delete :destroy, params: { id: img_to_rm.id }
      }.to change(Image, :count).by(-1)
    end

    it 'redirects to the images index with flash message' do
      delete :destroy, params: { id: image.id }
      expect(response).to redirect_to(admin_images_path)
      expect(flash[:success]).to be_present
    end
  end

end
