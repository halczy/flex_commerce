puts 'Seed file is running'

# USER
User.delete_all
puts 'Clear old user data'

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
puts "#{User.count} users created"

# CATEGORIES
Category.delete_all
puts 'Clear old category data'

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
puts "#{Category.count} categories created."
puts "Categories created #{Category.top_level.count} top level categories"

