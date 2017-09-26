require "selenium/webdriver"
require 'billy/capybara/rspec'
require 'phantomjs'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-popup-blocking
                              no-sandbox disable-gpu window-size=1920,1080) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path,
                                      timeout: 2.minute)
end

Capybara.register_driver :pg_billy do |app|
  options = {
    js_errors: true,
    phantomjs: Phantomjs.path,
    phantomjs_options: [
      '--ignore-ssl-errors=yes',
      "--proxy=#{Billy.proxy.host}:#{Billy.proxy.port}"
    ]
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

# Capybara.javascript_driver = :chrome
Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :pg_billy

Capybara.default_max_wait_time = 15
