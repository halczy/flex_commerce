require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe 'GET new' do
    it 'renders the new session template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:user) { FactoryBot.create(:customer) }

    it 'allows sign in through email' do
      post :create, params: { session: { ident: user.email,
                                         password: 'example' } }

      expect(session[:user_id]).to eq(user.id)
    end

    it 'allows sign in through cell number' do
      post :create, params: { session: { ident: user.cell_number,
                                         password: 'example' } }

      expect(session[:user_id]).to eq(user.id)
    end

    it "allows sign in through member id" do
      post :create, params: { session: { ident: user.member_id,
                                         password: 'example' } }
      expect(session[:user_id]).to eq(user.id)
    end

    it "allows sign in through dashed member id" do
      dashed_member_id = user.member_id.to_s.insert(3, '-')
      post :create, params: { session: { ident: dashed_member_id,
                                         password: 'example' } }
      expect(session[:user_id]).to eq(user.id)
    end

    it 'sets cookies and remember_token when remember me is selected' do
      post :create, params: { session: { ident: user.email,
                                         password: 'example',
                                         remember_me: '1' }}

      expect(cookies.signed['user_id']).to eql(user.id)
      expect(cookies['remember_token']).not_to be_nil
    end

    it 'goes back to login form when invalid ident is provided' do
      post :create, params: { session: { ident: 'wrong ident',
                                         password: 'wrong pass' } }

      expect(response).to render_template(:new)
      expect(flash[:warning]).to eq('Incorrect account / password combination')
      expect(session[:user_id]).to be_nil
    end

    it 'goes back to login form when incorrect password is provided' do
      post :create, params: { session: { ident: user.email,
                                         password: 'wrongpass' } }

      expect(response).to render_template(:new)
      expect(flash[:warning]).to eq('Incorrect account / password combination')
      expect(session[:user_id]).to be_nil
    end

    it 'cleans up session cart_id' do
      session[:cart_id] = FactoryBot.create(:cart).id
      post :create, params: { session: { ident: user.email, password: 'example' } }
      expect(session[:cart_id]).to be_nil
    end
  end

  describe 'DELETE destroy' do
    let(:user) { FactoryBot.create(:customer) }

    before do
      post :create, params: { session: { ident: user.email,
                                         password: 'example',
                                         remember_me: '1' } }
    end

    it 'clears session and cookies' do
      delete :destroy, params: { id: user.id }
      expect(session[:user_id]).to be_nil
      expect(response.cookies['user_id']).to be_nil
      expect(response.cookies['remember_token']).to be_nil
    end

    it 'redirects to root' do
      delete :destroy, params: { id: user.id }
      expect(response).to redirect_to root_url
      expect(flash[:info]).to eq('You are now logged out of your account')
    end
  end

end
