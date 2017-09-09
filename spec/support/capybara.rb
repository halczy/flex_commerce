require "selenium/webdriver"

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

# Capybara.javascript_driver = :chrome
Capybara.javascript_driver = :poltergeist

Capybara.default_max_wait_time = 15
