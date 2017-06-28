require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  let(:user) { FactoryGirl.create(:user) }

  describe '#login' do
    it 'writes user id to session' do
      helper.login(user)
      expect(session[:user_id]).to eql(user.id)
    end
  end

  describe '#logout' do
    it 'deletes user_id and remember_token in cookies' do
      # See sessions_controller. Cookies read/write is not supported here.
    end

    it 'sets remember_token to nil' do
      helper.logout(user)
      expect(helper.current_user).to be_nil
    end
  end

  describe '#current_user' do
    it 'returns @current_user if user has login session' do
      helper.login(user)
      expect(helper.current_user).to eql(user)
    end

    it 'returns @current_user if user has login cookies' do
      helper.remember(user)
      expect(helper.current_user).to eql(user)
    end

    it 'returns nil if user does not have login session nor cookies' do
      expect(helper.current_user).to be_nil
    end
  end

  describe '#signed_in?' do
    it 'returns true when @current_user is present' do
      helper.login(user)
      expect(helper.signed_in?).to be_truthy
    end

    it 'returns false when @current_user is not present' do
      expect(helper.signed_in?).to be_falsy
    end
  end

end
