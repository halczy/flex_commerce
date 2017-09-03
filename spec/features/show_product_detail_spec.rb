require 'rails_helper'

describe 'product detail' do
  before do
    Image.create(title: "Placeholder Image",
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))

    @cat = FactoryGirl.create(:category)
    @brand = FactoryGirl.create(:brand)
    @product_1 = FactoryGirl.create(:product, price_market: 100.01, price_member: 99.02)
    Categorization.create(category: @cat, product: @product_1)
    Categorization.create(category: @brand, product: @product_1)
  end

  it 'shows product detail information' do
    visit product_path(@product_1)

    expect(page).to have_content(@product_1.name)
    expect(page).to have_content(@product_1.tag_line)
    expect(page).to have_content(@product_1.sku)
    expect(page).to have_content(@product_1.categories.brand.first.name)
    expect(page).to have_content(@product_1.introduction)
    expect(page).to have_content(@product_1.price_market)
    expect(page).to have_content(@product_1.price_member)
    expect(page).to have_content(@product_1.description)
    expect(page).to have_content(@product_1.specification)
  end
end
