# I18n
I18n.locale = :'en-US'

# Application Name
ApplicationConfiguration.create(name: 'application_title', plain: 'Flex Commerce')
puts 'APPLICATIONCONFIGURATION: Created application title.'

# ADMIN
Admin.create(name: 'Admin User',
             email: 'admin@example.com',
             cell_number: '13811112222',
             password: 'example',
             password_confirmation: 'example')

puts "USER: #{Admin.count} admin created"

# PLACEHOLDER IMAGE
Image.create(title: "Placeholder Image",
             in_use: true,
             source_channel: 0,
             image: Rack::Test::UploadedFile.new(File.join(
                      Rails.root, 'public', 'placeholder_img',
                      'no-image-slide.png'), 'image/png'))
puts "IMAGE: #{Image.count} placeholder image created"

# CATEGORY - SPECIAL
Category.create(name: 'Feature Products',
                display_order: 0,
                flavor: 2,
                hide: false)
puts "CATEGORY: #{Category.special.count} special categories created."

# SHIPPING METHODS
shipping_delivery = ShippingMethod.create(name: 'Delivery',    variety: 1)

puts "SHIPPING METHOD: #{ShippingMethod.count} production shipping methods created."

# SHIPPING RATE
if Geo.count == 0
  raise('Geo data must be available. Run rails geo:setup to resolve is problem.')
end

Geo.province_state.each do |ps|
  ShippingRate.create(geo_code: ps.id,
                      init_rate: Faker::Number.decimal(2),
                      add_on_rate: Faker::Number.decimal(2),
                      shipping_method: shipping_delivery)
end
puts "SHIPPING RATE: #{ShippingRate.count} shipping rates created."
