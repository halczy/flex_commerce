require 'rails_helper'

RSpec.describe SessionsController, type: :controller do


  context 'GET new' do
    it 'renders the new session template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  context 'POST create' do
    let(:user_1) { FactoryGirl.create(:user) }

    it 'allow sign in through email' do
      post :create, params: { session: { ident: user_1.email,
                                         password: 'example' } }

      expect(response).to redirect_to(user_path(user_1))
    end
  end

end
