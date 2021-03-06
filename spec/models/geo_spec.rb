require 'rails_helper'

RSpec.describe Geo, type: :model do

  let(:country)  { FactoryBot.create(:country) }
  let(:province) { FactoryBot.create(:province) }
  let(:city)     { FactoryBot.create(:city) }
  describe 'creation' do
    it 'can be created' do
      expect(country).to be_valid
    end

    context 'validation' do
      it 'cannot be created without id' do
        geo = Geo.new(name: 'Random')
        expect(geo).not_to be_valid
      end

      it 'must have unique id' do
        dup_geo = Geo.new(id: country.id, name: 'Random')
        expect(dup_geo).not_to be_valid
      end

      it 'must have a name' do
        nameless = FactoryBot.build_stubbed(:country, name: nil)
        expect(nameless).not_to be_valid
      end
    end
  end

  describe 'relationships' do
    before do
      @parent = FactoryBot.create(:province)
      @child_1 = FactoryBot.create(:city, parent: @parent)
      @child_2 = FactoryBot.create(:city, parent: @parent)
    end

    it 'returns its parent' do
      expect(@child_1.parent).to eq(@parent)
      expect(@child_2.parent).to eq(@parent)
    end

    it 'returns its children' do
      expect(@parent.children).to match_array([@child_1, @child_2])
    end
  end

  describe 'scope' do
    before do
      @cn = FactoryBot.create(:country, id: '86')
      @province_1 = FactoryBot.create(:province, parent: @cn)
      @province_2 = FactoryBot.create(:province, parent: @cn)
      @city_1 = FactoryBot.create(:city, parent: @province_1)
      @city_2 = FactoryBot.create(:city, parent: @province_2)
      @district_1 = FactoryBot.create(:district, parent: @city_1)
      @district_2 = FactoryBot.create(:district, parent: @city_2)
      @community_1 = FactoryBot.create(:community, parent: @district_1)
      @community_2 = FactoryBot.create(:community, parent: @district_2)
    end

    it '#cn returns china' do
      expect(Geo.cn).to eq(@cn)
    end

    it '#provinces_states returns all provinces' do
      expect(Geo.province_state).to match_array([@province_1, @province_2])
    end

    it '#cities returns all cities' do
      expect(Geo.city).to match_array([@city_1, @city_2])
    end

    it '#districts reutrns all districts' do
      expect(Geo.district).to match_array([@district_1, @district_2])
    end

    it '#communities returns all communities' do
      expect(Geo.community).to match_array([@community_1, @community_2])
    end

  end
end
