require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  let(:user) { FactoryGirl.create(:user) }

  describe '#login' do
    it 'writes user id to session' do
      helper.login(user)
      expect(session[:user_id]).to eql(user.id)
    end
  end

  describe '#remember' do
    it 'sets user_id and remember_token in cookies' do
      # See user_controller_spec. Cookies read/write is not supported here.
    end

    it 'refreshes remember_token' do
      old_token = user.remember_token
      helper.remember(user)
      expect(old_token).not_to eql(user.remember_token)
    end

    it 'creates new remember_token' do
      user.remember_token = nil
      helper.remember(user)
      expect(user.remember_token).not_to be_nil
    end
  end

end
