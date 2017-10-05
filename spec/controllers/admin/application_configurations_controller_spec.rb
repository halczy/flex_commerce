require 'rails_helper'

RSpec.describe Admin::ApplicationConfigurationsController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:app_config) { ApplicationConfiguration.create(name: 'test_config',
                                                     value: 'test_value') }

  before { signin_as admin }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id: app_config.id }
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end
end
