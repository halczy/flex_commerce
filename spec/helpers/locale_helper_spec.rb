require 'rails_helper'

RSpec.describe LocaleHelper, type: :helper do

  describe '#store_locale' do
    it 'saves locale to session' do
      helper.store_locale('zh-CN')
      expect(session[:locale]).to eq('zh-CN')
    end

    it 'return false if unavilable locale is provided' do
      expect(helper.store_locale('1234567')).to be_falsy
    end
  end

  describe '#current_locale' do
    it 'returns locale from session' do
      session[:locale] = 'zh-CN'
      expect(helper.current_locale).to eq('zh-CN')
    end

    it 'returns locale from cookies' do
      helper.store_locale('zh-CN')
      session[:locale] = nil
      expect(helper.current_locale).to eq('zh-CN')
    end
  end

  describe '#clear_locale' do
    it 'removes locale from session' do
      helper.store_locale('zh-CN')
      helper.clear_locale
      expect(helper.current_locale).to be_nil
    end

    it 'removes locale from cookies' do
      helper.store_locale('zh-CN')
      session[:locale] = nil
      expect(helper.current_locale).to eq('zh-CN')
      helper.clear_locale
      expect(helper.current_locale).to be_nil
    end
  end
end
