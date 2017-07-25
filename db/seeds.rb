puts 'SEED: Seed file is running......'

# USER
User.delete_all
puts 'USER: Clear old user data'

Admin.create(name: 'Admin User',
             email: 'admin@example.com',
             cell_number: '13811112222',
             password: 'example',
             password_confirmation: 'example')

50.times do |n|
  Customer.create(name: Faker::Name.name,
                  email: "customer_#{n}@example.com",
                  cell_number: "186#{Faker::Number.number(8)}",
                  password: 'example',
                  password_confirmation: 'example')
end
puts "USER: #{User.count} users created"

# CATEGORIES
Category.delete_all
puts 'CATEGORY: Clear old category data'

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
puts "CATEGORY: Categories created #{Category.top_level.count} top level categories"
puts "CATEGORY: #{Category.count} categories created."

# PRODUCTS
Product.delete_all
puts 'PRODUCT: Clear old product data'

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
