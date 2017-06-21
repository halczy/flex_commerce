require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  context 'GET new' do
    it "renders the new user template" do
      get :new
      expect(response).to render_template("new")
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  context 'POST create' do
    describe 'user ident' do
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

    it 'can create user' do
      post :create, params: { user: { email: 'user_create@example.com',
                                      cell_number: '14900000000',
                                      name: 'User Create Test',
                                      password: 'example',
                                      password_confirmation: 'example' } }
      expect(assigns(:user).email).to eq('user_create@example.com')
      expect(assigns(:user).cell_number).to eq('14900000000')
      expect(assigns(:user).name).to eq('User Create Test')
    end
  end

end
