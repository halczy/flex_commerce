require 'rails_helper'

RSpec.describe LocalePreferenceController, type: :controller do

  describe 'POST create' do
    it 'sets locale to session and cookies' do
      post :create, params: { locale: 'zh-CN' }
      expect(session[:locale]).to eq('zh-CN')
      expect(cookies[:locale]).to eq('zh-CN')
    end

    it 'redirects to back root url without smart return' do
      post :create, params: { locale: 'zh-CN', return_back: true }
      expect(response).to redirect_to(root_url)
    end

    it 'redirects to previous location' do
      request.env['HTTP_REFERER'] = 'example.com'
      post :create, params: { locale: 'en-US', return_back: true }
      expect(response).to redirect_to('example.com')
    end

    it 'does not halt application if locale is not available' do
      post :create, params: { locale: 'es' }
      expect(response).to redirect_to(root_url)
    end
  end

  describe 'DELETE destroy' do
    before { post :create, params: { locale: 'zh-CN' } }

    it 'clears locale from session' do
      delete :destroy
      expect(session[:locale]).to be_nil
    end

    it 'redirects back to previous location' do
      request.env['HTTP_REFERER'] = 'example.com'
      post :destroy, params: { return_back: true }
      expect(response).to redirect_to('example.com')
    end
  end

end
