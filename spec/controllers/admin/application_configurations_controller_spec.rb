require 'rails_helper'

RSpec.describe Admin::ApplicationConfigurationsController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }

  before { signin_as admin }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end
end
