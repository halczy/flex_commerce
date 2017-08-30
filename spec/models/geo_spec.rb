require 'rails_helper'

RSpec.describe Geo, type: :model do

  let(:geo) { FactoryGirl.create(:geo) }

  describe 'creation' do
    it 'can be created' do
      expect(geo).to be_valid
    end

    context 'validation' do
      it 'cannot be created without id' do
        geo = Geo.new(name: 'Random')
        expect(geo).not_to be_valid
      end

      it 'must have unique id' do
        geo
        dup_geo = Geo.new(id: geo.id, name: 'Random')
        expect(dup_geo).not_to be_valid
      end

      it 'must have a name' do
        nameless = FactoryGirl.build_stubbed(:geo, name: nil)
        expect(nameless).not_to be_valid
      end
    end
  end

  describe 'relationships' do
    before do
      @parent = FactoryGirl.create(:geo, name: 'China', id: '86')
      @child_1 = FactoryGirl.create(:geo, name: 'Beijing', id: '100000', parent: @parent)
      @child_2 = FactoryGirl.create(:geo, name: 'Guangdong', id: '400000', parent: @parent)
    end

    it 'returns its parent' do
      expect(@child_1.parent).to eq(@parent)
      expect(@child_2.parent).to eq(@parent)
    end

    it 'returns its children' do
      expect(@parent.child_geos).to eq([@child_1, @child_2])
    end
  end
end
