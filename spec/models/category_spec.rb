require 'rails_helper'

RSpec.describe Category, type: :model do

  let(:cat) { FactoryGirl.create(:category) }

  describe 'creation' do
    it 'can be created with valid data' do
      expect(cat).to be_valid
    end

    context 'validation' do
      it 'cannot create without a name' do
        no_name_cat = FactoryGirl.build(:category, name: "")
        no_name_cat.valid?
        expect(no_name_cat.errors.messages[:name]).to include("can't be blank")
      end

      it 'cannot create with duplicate name' do
        FactoryGirl.create(:category, name: 'ABCD Cat')
        dup_cat = FactoryGirl.build(:category, name: 'ABCD Cat')
        dup_cat.valid?
        expect(dup_cat.errors.messages[:name]).to include('has already been taken')
      end

      it 'cannot create with negative display order' do
        neg_order = FactoryGirl.build(:category, display_order: -1)
        neg_order.valid?
        expect(neg_order.errors.messages[:display_order]).
          to include('must be greater than or equal to 0')
      end

      it 'cannot have an non-existence parent' do
        fake_parent = FactoryGirl.build(:category, parent_id: 9999999)
        fake_parent.valid?
        expect(fake_parent.errors.messages[:parent_id]).
          to include('category with this ID does not exist')
      end
    end
  end

  describe 'relationships' do
    before do
      @main_cat = FactoryGirl.create(:category)
      @hidden_cat = FactoryGirl.create(:category, hide: true)
      @child_cat_1 = FactoryGirl.create(:category, parent: @main_cat)
      @child_cat_2 = FactoryGirl.create(:category, parent: @main_cat)
    end

    it 'can have child categories' do
      expect(@main_cat.child_categories).
        to match_array([@child_cat_1, @child_cat_2])
    end

    it 'can retrives parent category' do
      expect(@child_cat_1.parent).to eq(@main_cat)
      expect(@child_cat_2.parent).to eq(@main_cat)
    end

    context 'scope' do
      it 'scopes visible category without parent as top level menu' do
        expect(Category.top_level).to eq([@main_cat])
      end

      it 'scopes categories without parent' do
        expect(Category.no_parent).to eq([@main_cat, @hidden_cat])
      end
    end
  end

end
