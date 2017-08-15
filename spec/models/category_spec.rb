require 'rails_helper'

RSpec.describe Category, type: :model do

  let(:cat)   { FactoryGirl.create(:category) }
  let(:brand) { FactoryGirl.create(:brand) }

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
      @special_cat = FactoryGirl.create(:feature)
    end

    it 'can have child categories' do
      expect(@main_cat.child_categories).
        to match_array([@child_cat_1, @child_cat_2])
    end

    it 'can retrives parent category' do
      expect(@child_cat_1.parent).to eq(@main_cat)
      expect(@child_cat_2.parent).to eq(@main_cat)
    end

    context '#unassociate_child' do
      it 'removes parent id from child categories' do
        @main_cat.unassociate_children
        expect(@main_cat.reload.child_categories).to be_empty
        expect(@child_cat_1.reload.parent).to be_nil
        expect(@child_cat_2.reload.parent).to be_nil
      end
    end

    context 'scope' do
      it 'scopes visible category without parent as top level menu' do
        expect(Category.top_level).to eq([@main_cat])
      end

      it 'scopes categories without parent' do
        expect(Category.no_parent).to eq([@main_cat, @hidden_cat])
      end

      it 'scopes normal categories' do
        expect(Category.regular).not_to include(@special_cat)
        expect(Category.regular).to include(@main_cat)
      end

      it 'scopes special categories' do
        expect(Category.special).to eq([@special_cat])
      end
    end

    context 'enum' do
      it 'can set category as feature' do
        feature_cat = FactoryGirl.create(:feature)
        expect(feature_cat.flavor).to eq('feature')
      end

      it 'can set category as brand' do
        brand_cat = FactoryGirl.create(:brand)
        expect(brand_cat.flavor).to eq('brand')
      end
    end
  end

  describe '#move' do
    let(:cat_order_init_5) { FactoryGirl.create(:category, display_order: 5) }

    it 'lower display order by 1' do
      cat_order_init_5.move(-1)
      expect(cat_order_init_5.reload.display_order).to eq(4)
    end

    it 'increase display order by 1 ' do
      cat_order_init_5.move(1)
      expect(cat_order_init_5.reload.display_order).to eq(6)
    end

    it 'display_order cannot be negative' do
      cat_order_init_5.move(-100)
      expect(cat_order_init_5.reload.display_order).to eq(5)
    end
  end

  describe '#refine' do
    context 'brand category' do
      it 'returns regular categories associted with category products' do
        product_1 = FactoryGirl.create(:product)
        product_2 = FactoryGirl.create(:product)
        cat_1 = FactoryGirl.create(:category)
        cat_2 = FactoryGirl.create(:category)
        Categorization.create(category: brand, product: product_1)
        Categorization.create(category: brand, product: product_2)
        Categorization.create(category: cat_1, product: product_1)
        Categorization.create(category: cat_2, product: product_2)

        expect(brand.refine).to match_array([cat_1, cat_2])
      end
    end

    context 'regular category' do
      it 'returns brand categories associted with category products' do
        product_1 = FactoryGirl.create(:product)
        product_2 = FactoryGirl.create(:product)
        Categorization.create(category: cat, product: product_1)
        Categorization.create(category: cat, product: product_2)
        Categorization.create(category: brand, product: product_1)
        Categorization.create(category: brand, product: product_2)

        expect(cat.refine).to match_array(brand)
      end
    end

    context 'empty category' do
      it 'returns an empty category list' do
        expect(cat.refine).to match_array([])
      end
    end
  end

end
