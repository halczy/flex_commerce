require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe 'GET #homepage' do
    it 'responds successfully' do
      get :homepage
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

end
