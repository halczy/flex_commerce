require 'rails_helper'

RSpec.describe SessionsController, type: :controller do


  context 'GET new' do
    it 'renders the new session template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  context 'POST create' do
    let(:user) { FactoryGirl.create(:user) }

    it 'allows sign in through email' do
      post :create, params: { session: { ident: user.email,
                                         password: 'example' } }

      expect(response).to redirect_to(user_path(user))
      expect(session[:user_id]).to eq(user.id)
    end

    it 'allows sign in through cell number' do
      post :create, params: { session: { ident: user.cell_number,
                                         password: 'example' } }
      expect(response).to redirect_to(user_path(user))
      expect(session[:user_id]).to eq(user.id)
    end

    it 'renders new template again when invalid ident is provided' do
      post :create, params: { session: { ident: 'wrong ident',
                                         password: 'wrong pass' } }
      expect(response).to render_template(:new)
      expect(session[:user_id]).to be_nil
    end

    it 'renders new template again when incorrect password is provided' do
      post :create, params: { session: { ident: user.email,
                                         password: 'wrongpass' } }
      expect(response).to render_template(:new)
      expect(session[:user_id]).to be_nil
    end
  end

end
