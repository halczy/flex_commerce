require 'rails_helper'

RSpec.describe Admin::CustomersController, type: :controller do

  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end
  end
end
