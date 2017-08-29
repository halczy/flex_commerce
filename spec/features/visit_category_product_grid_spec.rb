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
    @product_1 = FactoryGirl.create(:product, price_member: 900.01)
    @product_2 = FactoryGirl.create(:product, price_member: 100.02)
    @product_3 = FactoryGirl.create(:product, price_member: 500.03)
    @product_4 = FactoryGirl.create(:product, price_member: 700.03, status: 0)
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
      expect(page).not_to have_content(@product_4.name)
    end

    it 'displays products price' do
      visit(category_path(@cat))

      expect(page).to have_content(@product_1.price_member)
      expect(page).to have_content(@product_2.price_member)
      expect(page).to have_content(@product_3.price_member)
      expect(page).not_to have_content(@product_4.price_member)
      expect(page).to have_content('Detail', count: 3)
      expect(page).to have_content('Add to Cart', count: 3)
    end
  end

  context 'side card - search'  do
    # Set up as standalone spec in feature/search_products_spec.rb
  end

  context 'side card - sort', js: true do
    it 'sorts product prices from low to high' do
      visit(category_path(@cat))
      select 'Price From Low to High'
      expect(page).not_to have_content("Add to Cart #{@product_2.name}")
      expect(page).to have_content("Add to Cart #{@product_1.name}")
    end

    it 'sorts product prices from high to low' do
      visit(category_path(@cat))
      select 'Price From High to Low'
      expect(page).not_to have_content("Add to Cart #{@product_1.name}")
      expect(page).to have_content("Add to Cart #{@product_3.name}")
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

  context 'pagination' do
    before do
      20.times do
        product = FactoryGirl.create(:product)
        Categorization.create(category: @cat, product: product)
      end
    end

    it 'returns page selector' do
      visit category_path(@cat)

      expect(page).to have_content('Next')
      expect(page).to have_content('Last')
    end

    it "returns only six products per page" do
      visit category_path(@cat)

      expect(page).to have_content('Add to Cart', count: 6)
    end

    it "returns only X products in the last page" do
      visit category_path(@cat)
      click_on('Last')

      expect(page).to have_content('Add to Cart', count: 5)
    end

  end
end
