namespace :flex do
  desc 'Build demo/seed data'
  task demo: :environment do
    puts 'Building demo data......'

    # Set locale
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


    # Build Geo
    Rake::Task['geo:setup'].invoke
    puts "GEO: #{Geo.count} geos created."
    
    # SHIPPING METHODS
    shipping_delivery = ShippingMethod.create(name: 'Delivery',    variety: 1)

    puts "SHIPPING METHOD: #{ShippingMethod.count} production shipping methods created."

    # SHIPPING RATE
    if Geo.count == 0
      raise('Geo data must be available. Run rails geo:setup to resolve this problem.')
    end

    Geo.province_state.each do |ps|
      ShippingRate.create(geo_code: ps.id,
                          init_rate: Faker::Number.decimal(2),
                          add_on_rate: Faker::Number.decimal(2),
                          shipping_method: shipping_delivery)
    end
    puts "SHIPPING RATE: #{ShippingRate.count} shipping rates created."

    # USERS
    50.times do |n|
      Customer.create(name: Faker::Name.name,
                      email: "customer_#{n}@example.com",
                      cell_number: "186#{Faker::Number.number(8)}",
                      password: 'example',
                      password_confirmation: 'example')
    end
    puts "USER: #{Customer.count} customer created"

    # CATEGORIES
    10.times do
      Category.create(name: Faker::Company.name,
                      display_order: 0,
                      flavor: 1,
                      hide: false)
    end
    puts "CATEGORY: #{Category.brand.count} brand categories created."

    5.times do |n|
      current_cat = Category.create(name: Faker::Space.galaxy,
                                    display_order: n,
                                    flavor: 0,
                                    hide: false)
      10.times do
        Category.create(name: Faker::Space.star,
                        display_order: n,
                        flavor: 0,
                        hide: false,
                        parent: current_cat)
      end
    end
    puts "CATEGORY: #{Category.top_level.count} top level categories created"
    puts "CATEGORY: #{Category.count} total categories created."

    # PRODUCTS
    500.times do |n|
      Product.create(name: Faker::Commerce.product_name,
                     tag_line: Faker::Coffee.origin,
                     sku: Faker::Number.unique.number(10),
                     weight: Faker::Number.decimal(2),
                     introduction: Faker::Coffee.notes,
                     description: Faker::Lorem.paragraph,
                     specification: Faker::Lorem.paragraph,
                     price_market: Faker::Number.decimal(4, 2).to_f,
                     price_member: Faker::Number.decimal(3, 2).to_f,
                     price_reward: Faker::Number.decimal(2, 2).to_f,
                     cost: Faker::Number.decimal(1, 2).to_f,
                     strict_inventory: true,
                     digital: false)
    end
    puts "PRODUCT: #{Product.count} products created."

    # Categorization
    5.times do
      product = Product.all.sample
      product.categorizations.create(category: Category.special.first)
    end
    puts "Categorization: #{Categorization.count} product-feature category relationships created."

    100.times do
      product = Product.all.sample
      product.categorizations.create(category: Category.brand.sample)
    end
    puts "Categorization: #{Categorization.count} product-brand relationships created."

    100.times do
      product = Product.all.sample
      product.categorizations.create(category: Category.children.sample)
    end
    puts "Categorization: #{Categorization.count} product-category relationships created."

    # IMAGES
    images = ['img_1.jpeg', 'img_2.jpeg', 'img_3.jpeg', 'img_4.jpeg']
    Category.special.first.products.each do |product|
      5.times do |n|
        Image.create(title: "Seed file #{n}",
                     imageable_type: 'Product',
                     imageable_id: product.id,
                     in_use: true,
                     source_channel: 0,
                     image: Rack::Test::UploadedFile.new(File.join(
                              Rails.root, 'spec', 'support', 'files',
                              images.sample), 'image/jpeg'))
      end
    end
    puts "IMAGE: #{Image.count} images created."

    # INVENTORIES
    1000.times do
      Product.all.sample.inventories.create(status: 0)
    end
    puts "INVENTORY: #{Inventory.count} inventories created."

    # SHIPPING METHOD
    shipping_pickup = FactoryBot.create(:self_pickup_sa)
    pickup_rate = ShippingRate.new(geo_code: '*', init_rate: '0', add_on_rate: '0')
    shipping_pickup.shipping_rates << pickup_rate
    pickup_address = Address.new(province_state: Geo.province_state.sample.id,
                                 street: ' Sample Street',
                                 recipient: 'John Doe',
                                 contact_number: '18000000000',
                                 addressable: shipping_pickup)
    pickup_address.build_full_address

    puts 'SHIPPING METHOD: 2 shipping methods created.'

    Product.all.each do |product|
      product.shipping_methods << shipping_delivery
      product.shipping_methods << shipping_pickup
    end

    puts 'SHIPPING METHOD: Added shipping method to all products.'

    # REWARD METHODS
    ref_reward = RewardMethod.create(name: 'Referral Reward',
                                     variety: 0,
                                     settings: { percentage: 5 })
    cash_back = RewardMethod.create(name: 'Cash Back',
                                    variety: 1,
                                    settings: { percentage: 5 })
    puts "REWARD METHOD: #{RewardMethod.count} reward methods created."

    Product.all.each do |product|
      product.reward_methods << ref_reward
      product.reward_methods << cash_back
    end
    puts 'REWARD METHOD: Applied reward methods to all products.'
  end
end
