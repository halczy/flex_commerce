require 'rails_helper'

RSpec.describe Admin::GeosController, type: :controller do

  let(:admin)    { FactoryBot.create(:admin) }
  let(:customer) { FactoryBot.create(:customer) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

    context 'filters' do
      it 'returns all geos by default' do
        get :index, params: { geo_filter: '' }
        expect(assigns(:geos).count).to eq(Geo.count)
      end

      it 'returns countries' do
        get :index, params: { geo_filter: 'country_region' }
        expect(assigns(:geos).count).to eq(Geo.country_region.count)
      end

      it 'returns province_state' do
        get :index, params: { geo_filter: 'province_state' }
        expect(assigns(:geos).count).to eq(Geo.province_state.count)
      end
      it 'returns cities' do
        get :index, params: { geo_filter: 'city' }
        expect(assigns(:geos).count).to eq(Geo.city.count)
      end
      it 'returns districts' do
        get :index, params: { geo_filter: 'district' }
        expect(assigns(:geos).count).to eq(Geo.district.count)
      end
      it 'returns communities' do
        get :index, params: { geo_filter: 'community' }
        expect(assigns(:geos).count).to eq(Geo.community.count)
      end
    end

    context 'access control' do
      it 'rejects non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET search' do
    before do
      @city = FactoryBot.create(:city)
      @community = FactoryBot.create(:community)
    end

    it 'responses with search result' do
      get :search, params: { search_term: @city.name }
      expect(response).to render_template(:search)
      expect(assigns(:search_result)).to match_array([@city])
    end

    it 'responses with empty serach result' do
      get :search, params: { search_term: 'random random random string' }
      expect(response).to be_success
      expect(flash).not_to be_present
      expect(assigns(:search_result)).to be_empty
    end

    it 'renders warning message when empty serach term is provided' do
      get :search, params: { search_term: '' }
      expect(response).to render_template(:search)
      expect(flash[:warning]).to be_present
    end
  end
end
