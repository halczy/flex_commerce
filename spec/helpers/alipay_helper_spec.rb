require 'rails_helper'

RSpec.describe AlipayHelper, type: :helper do

  describe '#create_alipay_client' do
    it 'creates an alipay client' do
      expect(helper.create_alipay_client).to be_an_instance_of Alipay::Client
    end
  end

end
