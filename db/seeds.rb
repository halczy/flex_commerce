# USER
User.delete_all

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

# CATEGORIES
Category.delete_all

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
