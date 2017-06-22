require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  let(:user_1) { FactoryGirl.create(:user) }

  describe '#login' do
    it 'writes user id to session' do
      helper.login(user_1)
      expect(session[:user_id]).to eql(user_1.id)
    end
  end

end
