module AlipayEnvHelpers
  def set_alipay_env
    ENV['API_RETURN_ROOT'] = "https://example.com"
    ENV['ALIPAY_APP_ID'] = "20160000000000000"
    ENV['ALIPAY_GATEWAY'] = "https://openapi.alipaydev.com/gateway.do"
    ENV['ALIPAY_APP_PRIVATE_KEY'] = OpenSSL::PKey::RSA.new(2048).to_s
    ENV['ALIPAY_PUBLIC_KEY'] = OpenSSL::PKey::RSA.new(2048).public_key.to_s
  end

end

RSpec.configure do |c|
  c.include AlipayEnvHelpers
end
