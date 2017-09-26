require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }

  before { signin_as admin }

  describe 'GET index' do
    before do
    end

    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end
  end

end
