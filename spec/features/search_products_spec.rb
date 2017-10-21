require 'rails_helper'

describe 'Product Search' do

  before do
    Image.create(title: "Placeholder Image",
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))

    @product_1 = FactoryBot.create(:product, name: 'Red Sun')
    @product_2 = FactoryBot.create(:product, name: 'Blue Sun')
    @product_3 = FactoryBot.create(:product, name: 'Green Sun')
    @category = FactoryBot.create(:category)
    Categorization.create(category: @category, product: @product_1)
    Categorization.create(category: @category, product: @product_2)
  end

  it "returns matching products" do
    visit category_path(@category)
    fill_in 'search_term', with: 'Sun'
    click_on('Go')

    expect(page).to have_content(@product_1.name)
    expect(page).to have_content(@product_2.name)
    expect(page).to have_content(@product_3.name)
  end

  it "returns matching products in category" do
    visit category_path(@category)
    fill_in 'search_term', with: 'Sun'
    check('Limit to this category')
    click_on('Go')

    expect(page).to have_content(@product_1.name)
    expect(page).to have_content(@product_2.name)
  end

  it "flash alert when no keywords is entered" do
    visit category_path(@category)
    click_on('Go')

    expect(page).to have_css(".alert-warning")
  end

  it "display no matching message when no products match" do
    visit category_path(@category)
    fill_in 'search_term', with: '1239kaevwo'
    click_on('Go')

    expect(page).to have_content('No Matching Product Found')
  end

  context 'result counter' do
    it "displays correct result count" do
      visit category_path(@category)
      fill_in 'search_term', with: 'Blue Sun'
      click_on('Go')

      expect(page).to have_content('1 Product Found')
    end

    it "displays zero result count when no match" do
      visit category_path(@category)
      fill_in 'search_term', with: 'owoalerlef'
      click_on('Go')

      expect(page).to have_content('0 Products Found')
    end
  end


end
