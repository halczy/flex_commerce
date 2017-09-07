require 'rails_helper'

RSpec.describe Admin::GeosController, type: :controller do

  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

    context 'filters' do
      it 'returns countries'
      it 'returns province_state'
      it 'returns cities'
      it 'returns districts'
      it 'returns communities'
    end

    context 'access control' do
      it 'rejects non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
