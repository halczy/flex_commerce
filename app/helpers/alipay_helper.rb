module AlipayHelper

  def create_alipay_client
    get_alipay_params
    Alipay::Client.new(
      url: @gateway,
      app_id: @app_id,
      app_private_key: @private_key,
      alipay_public_key: @public_key
    )
  end

  def get_alipay_params
    @gateway =     ApplicationConfiguration.get('alipay_gateway') ||
                   ENV['ALIPAY_GATEWAY']
    @app_id =      ApplicationConfiguration.get('alipay_app_id') ||
                   ENV['ALIPAY_APP_ID']
    @private_key = ApplicationConfiguration.get('alipay_app_private_key') ||
                   ENV['ALIPAY_APP_PRIVATE_KEY']
    @public_key  = ApplicationConfiguration.get('alipay_public_key') ||
                   ENV['ALIPAY_PUBLIC_KEY']
  end
end
