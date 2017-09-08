require 'rails_helper'

RSpec.describe Admin::ShippingMethodsController, type: :controller do

  let(:admin)       { FactoryGirl.create(:admin) }
  let(:delivery)    { FactoryGirl.create(:delivery) }
  let(:no_shipping) { FactoryGirl.create(:no_shipping) }
  let(:self_pickup) { FactoryGirl.create(:self_pickup) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end
  end
end
