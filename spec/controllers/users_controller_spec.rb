require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'GET new' do
    it "renders the new user template" do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST create' do
    context 'user identifier' do
      it 'can identify when user enter an email' do
        post :create, params: { user: { ident: 'ident_user_1@example.com',
                                        password: 'example',
                                        password_confirmation: 'example' } }
        expect(response).to redirect_to(user_path(User.last))
        expect(assigns(:user).email).to eq('ident_user_1@example.com')
      end

      it 'can identify when user enter a cell number' do
        post :create, params: { user: { ident: '17612345678',
                                        password: 'example',
                                        password_confirmation: 'example' } }
        expect(response).to redirect_to(user_path(User.last))
        expect(assigns(:user).cell_number).to eq('17612345678')
      end

      it 'catches invalid ident' do
        post :create, params: { user: { ident: 'i23ji4of3',
                                        password: '',
                                        password_confirmation: '' } }
        expect(response).to render_template(:new)
      end

      it 'catches empty ident' do
        post :create, params: { user: { ident: '' }}
        expect(response).to render_template(:new)
      end
    end

    describe 'user creation' do
      before do
        post :create, params: { user: { email: 'user_create@example.com',
                                        cell_number: '14900000000',
                                        name: 'User Create Test',
                                        password: 'example',
                                        password_confirmation: 'example' } }
      end

      it 'creates user with correct attributes' do
        expect(assigns(:user).email).to eq('user_create@example.com')
        expect(assigns(:user).cell_number).to eq('14900000000')
        expect(assigns(:user).name).to eq('User Create Test')
      end

      it 'creates user as customer' do
        expect(assigns(:user).type).to eq('Customer')
        expect(assigns(:user).customer?).to be_truthy
      end
    end
  end

  describe 'GET show' do
    let(:customer)       { FactoryGirl.create(:customer) }
    let(:other_customer) { FactoryGirl.create(:customer) }

    it 'renders show page for signed in user' do
      signin_as(customer)
      get :show, params: { id: customer.id }
      expect(response).to render_template(:show)
    end

    describe 'access control' do
      it 'requires user to be signed in' do
        get :show, params: { id: customer.id }
        expect(response).to redirect_to(signin_path)
      end

      it 'only allows user to see their own profile' do
        signin_as(other_customer)
        get :show, params: { id: customer.id }
        expect(response).to redirect_to(root_url)
      end

      it 'allow admin to access user profile'
    end
  end

end
