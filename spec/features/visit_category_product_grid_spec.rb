require 'rails_helper'

describe 'category_grid' do
  before do
    Image.create(title: "Placeholder Image",
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))

    @cat = FactoryGirl.create(:category)
    @brand = FactoryGirl.create(:brand)
    @product_1 = FactoryGirl.create(:product)
    @product_2 = FactoryGirl.create(:product)
    @product_3 = FactoryGirl.create(:product)
    Categorization.create(category: @cat, product: @product_1)
    Categorization.create(category: @cat, product: @product_2)
    Categorization.create(category: @cat, product: @product_3)
    Categorization.create(category: @brand, product: @product_1)
    Categorization.create(category: @brand, product: @product_2)
  end

  context 'product' do
    it 'displays the products in the category' do
      visit root_path
      click_on(@cat.name)

      expect(page.current_path).to eq(category_path(@cat))
      expect(page).to have_content(@cat.name)
      expect(page).to have_content(@product_1.name)
      expect(page).to have_content(@product_2.name)
      expect(page).to have_content(@product_3.name)
    end

    it 'displays products price' do
      visit(category_path(@cat))

      expect(page).to have_content(@product_1.price_member)
      expect(page).to have_content(@product_2.price_member)
      expect(page).to have_content(@product_3.price_member)
      expect(page).to have_content('Detail', count: 3)
      expect(page).to have_content('Add to Cart', count: 3)
    end
  end

  context 'side card - refine' do
    it 'displays brands with product count in regular category' do
      visit(category_path(@cat))

      expect(page).to have_content("#{@brand.name} (#{@brand.products.count}")
    end

    it 'displays categories with product count in brand category ' do
      visit(category_path(@brand))
      expect(page).to have_content("#{@cat.name} (#{@cat.products.count}")
    end
  end
end
