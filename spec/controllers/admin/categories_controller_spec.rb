require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }
  let(:category) { FactoryGirl.create(:category) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end

    it 'returns an instance of regular categories' do
      FactoryGirl.create(:category)
      get :index
      expect(assigns(:top_level).first.flavor).to eq('regular')
    end

    it 'returns an instance of brand categoreis' do
      FactoryGirl.create(:brand)
      get :index
      expect(assigns(:brands).first.flavor).to eq('brand')
    end

    it 'returns an instance of special categories' do
      FactoryGirl.create(:feature)
      get :index
      expect(assigns(:special).first.flavor).to eq('feature')
    end

    context 'access control' do
      it 'does not allow non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET new' do
    it 'responses successfully' do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe 'POST create' do
    describe 'category creation' do
      context 'with valid params' do

        let(:category_attrs) { FactoryGirl.attributes_for(:category) }

        it 'creates regular category' do
          category_attrs[:flavor] = 'regular'
          post :create, params: { category: category_attrs }
          expect(response).to redirect_to(admin_category_path(Category.last))
          expect(flash[:success]).to be_present
        end

        it 'creates brand category' do
          category_attrs[:flavor] = 'brand'
          post :create, params: { category: category_attrs }
          expect(response).to redirect_to(admin_category_path(Category.last))
          expect(assigns(:category).flavor).to eq('brand')
        end

        it 'creates feature category' do
          category_attrs[:flavor] = 'feature'
          post :create, params: { category: category_attrs }
          expect(response).to redirect_to(admin_category_path(Category.last))
          expect(Category.special.count).to eq(1)
        end
      end

      context 'with invalid params' do
        it 'does not create and renders new action' do
          post :create, params: { category: { parent_id: 9999,
                                              name: 'Invalid Cat'},
                                              display_order: 0 }
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id: category.id }
      expect(response).to render_template(:edit)
      expect(assigns(:category)).to be_an_instance_of(Category)
    end
  end

  describe 'PATCH update' do
    it 'updates with valid params' do
      patch :update, params: { id: category.id,
                               category: { name: 'New Name',
                                           display_order: 10 } }
      expect(category.reload.name).to eq('New Name')
      expect(category.reload.display_order).to eq(10)
      expect(response).to redirect_to(admin_category_path(category))
      expect(flash[:success]).to be_present
    end

    it 'rejects update action when given invalid params' do
      patch :update, params: { id: category.id,
                               category: { parent_id: 9999999} }
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE destroy' do
    it 'destroys category' do
      cat_1 = category
      cat_2 = FactoryGirl.create(:category, parent: cat_1)
      delete :destroy, params: { id: cat_1.id }
      expect(response).to redirect_to(admin_categories_path)
      expect{cat_1.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect(cat_2.reload.parent).to be_nil
    end
  end

  describe 'PATCH move' do
    let(:cat_order_init_1) { FactoryGirl.create(:category, display_order: 1) }

    it 'increase category position' do
      patch :move, params: { id: cat_order_init_1.id, position: 1 }
      expect(response).to redirect_to admin_categories_path
      expect(cat_order_init_1.reload.display_order).to eq(2)
    end

    it 'decrease category position' do
      patch :move, params: { id: cat_order_init_1.id, position: -1 }
      expect(response).to redirect_to admin_categories_path
      expect(cat_order_init_1.reload.display_order).to eq(0)
    end

    it 'disregard invalid params' do
      patch :move, params: { id: cat_order_init_1.id, position: -100 }
      expect(response).to redirect_to admin_categories_path
      expect(cat_order_init_1.reload.display_order).to eq(1)
      expect(flash[:danger]).to eq('Cannot move category to that position.')
    end

    it 'does not move category when no position params is given' do
      patch :move, params: { id: cat_order_init_1.id }
      expect(response).to redirect_to admin_categories_path
      expect(cat_order_init_1.reload.display_order).to eq(1)
    end
  end

end
