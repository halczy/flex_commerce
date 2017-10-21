namespace :flex do
  desc 'Setup for production environment'
  task setup: :environment do
    # Set Application Name
    puts 'Enter Application Name'
    app_name = STDIN.gets.chomp
    ApplicationConfiguration.create(
      name: 'application_title',
      plain: app_name
    )
    puts 'App. name created successfully' if ApplicationConfiguration.count == 1
    puts

    # Admin Account
    puts 'Enter Admin Email'
    email = STDIN.gets.chomp
    puts 'Enter Admin Password'
    password = STDIN.gets.chomp
    Admin.create(
      email: email,
      password: password,
      password_confirmation: password
    )
    puts 'Admin account created successfully' if Admin.count == 1
    puts

    # PLACEHOLDER IMAGE
    Image.create(title: 'Placeholder Image',
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))

    # CATEGORY - SPECIAL
    Category.create(name: 'Feature Products',
                    display_order: 0,
                    flavor: 2,
                    hide: false)

    # Build Geo
    puts 'Importing geo data. This might take a while.'
    Rake::Task['geo:setup'].invoke

    # SHIPPING METHODS
    shipping_delivery = ShippingMethod.create(name: 'Delivery|快递', variety: 1)
    Geo.province_state.each do |ps|
      ShippingRate.create(geo_code: ps.id,
                          init_rate: 0,
                          add_on_rate: 0,
                          shipping_method: shipping_delivery)
    end

    puts 'Setup Completed!'
  end
end
