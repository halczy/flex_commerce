require 'rails_helper'

RSpec.describe AlipayHelper, type: :helper do

  describe '#create_alipay_client' do
    it 'creates an alipay client' do
      expect(helper.create_alipay_client).to be_an_instance_of Alipay::Client
    end

    it 'creates an alipay client with correct params' do
      ENV['ALIPAY_GATEWAY'] = 'https://example.com'
      ApplicationConfiguration.create(name: 'alipay_app_id', plain: '4321')
      key = OpenSSL::PKey::RSA.new(2048)
      ApplicationConfiguration.create(name: 'alipay_app_private_key', value: key.to_s)
      ApplicationConfiguration.create(name: 'alipay_public_key', value: key.public_key.to_s)
      client = create_alipay_client

      expect(client.instance_values['url']).to eq('https://example.com')
      expect(client.instance_values['app_id']).to eq('4321')
      expect(client.instance_values['app_private_key']).to eq(key.to_s)
      expect(client.instance_values['alipay_public_key']).to eq(key.public_key.to_s)
    end
  end

  describe 'get_alipay_params' do
    it 'gets params from environment variable' do
      ENV['ALIPAY_APP_ID'] = '1234'
      get_alipay_params
      expect(@app_id).to eq('1234')
    end

    it 'gets params from app configs' do
      ApplicationConfiguration.create(name: 'alipay_gateway', value: 'abc.com')
      get_alipay_params
      expect(@gateway).to eq('abc.com')
    end
  end

end
