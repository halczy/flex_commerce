puts 'SEED: Seed file is running......'

# CLEAN UP
User.destroy_all
puts 'USER: Clear old user data'
Product.destroy_all
puts 'PRODUCT: Clear old product data'
Categorization.destroy_all
Category.destroy_all
puts 'CATEGORY: Clear old category data'
Image.destroy_all
puts 'IMAGE: Clear old image data'



# USER
Admin.create(name: 'Admin User',
             email: 'admin@example.com',
             cell_number: '13811112222',
             password: 'example',
             password_confirmation: 'example')

puts "USER: #{Admin.count} admin created"

50.times do |n|
  Customer.create(name: Faker::Name.name,
                  email: "customer_#{n}@example.com",
                  cell_number: "186#{Faker::Number.number(8)}",
                  password: 'example',
                  password_confirmation: 'example')
end
puts "USER: #{Customer.count} customer created"

# CATEGORIES
Category.create(name: 'Feature Products',
                display_order: 0,
                flavor: 1,
                hide: false)
puts "CATEGORY: #{Category.special.count} special categories created."

5.times do |n|
  current_cat = Category.create(name: Faker::Space.galaxy,
                                display_order: n,
                                flavor: 0,
                                hide: false)
  3.times do |n|
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
100.times do |n|
  Product.create(name: Faker::Commerce.product_name,
                 tag_line: Faker::Coffee.origin,
                 sku: Faker::Number.unique.number(10),
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
puts "Categorization: #{Categorization.count} product-categorie relationships created."

# IMAGES
images = ['img_1.jpeg', 'img_2.jpeg', 'img_3.jpeg', 'img_4.jpeg']
Category.special.first.products.each do |product|
  5.times do |n|
    image = Image.create(title: "Seed file #{n}",
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

