FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    tag_line { Faker::Coffee.origin }
    sku { Faker::Number.unique.number(10) }
    weight { Faker::Number.decimal(2) }
    introduction { Faker::Coffee.notes }
    description { Faker::Lorem.paragraph }
    specification { Faker::Lorem.paragraph }
    price_market { Faker::Number.decimal(4, 2).to_f }
    price_member { Faker::Number.decimal(3, 2).to_f }
    price_reward { Faker::Number.decimal(2, 2).to_f }
    cost { Faker::Number.decimal(1, 2).to_f }
    status 1

    transient do
      purchase_ready false
      reward         false
    end

    after(:create) do |product, evaluator|
      if evaluator.purchase_ready
        3.times { FactoryBot.create(:inventory, product: product) }
        product.shipping_methods << FactoryBot.create(:delivery)
        product.shipping_methods << FactoryBot.create(:self_pickup)
        product.shipping_methods << FactoryBot.create(:no_shipping)
        product.images << FactoryBot.create(:image)
      end

      if evaluator.reward
        product.reward_methods << FactoryBot.create(:ref_reward, no_products: true)
        product.reward_methods << FactoryBot.create(:cash_back, no_products: true)
      end
    end
  end
end
