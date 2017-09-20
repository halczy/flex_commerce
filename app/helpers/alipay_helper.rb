module AlipayHelper

  def create_alipay_client
    Alipay::Client.new(url: ENV['ALIPAY_GATEWAY'],
                       app_id: ENV['ALIPAY_APP_ID'],
                       app_private_key: ENV['ALIPAY_APP_PRIVATE_KEY'],
                       alipay_public_key: ENV['ALIPAY_PUBLIC_KEY'])
  end

end
