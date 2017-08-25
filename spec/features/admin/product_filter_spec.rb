require 'rails_helper'

describe 'Product Index Filter' do
  
  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

  before do
    @product_in_stock = FactoryGirl.create(:product)
    @product_oos = FactoryGirl.create(:product)
    FactoryGirl.create(:inventory, product: @product_in_stock)
    FactoryGirl.create(:inventory, product: @product_oos, status: 4)
    visit admin_products_path
  end

  it "does not filter products without params" do
    expect(page).to have_content(@product_in_stock.name)
    expect(page).to have_content(@product_oos.name)
  end

  it "does not filter products with empty display param", js: true do
    select 'No Filter'
    expect(page).to have_content(@product_in_stock.name)
    expect(page).to have_content(@product_oos.name)
  end

  it "filters to display only in stock proudcts", js: true do
    select 'In Stock'
    expect(page).to have_content(@product_in_stock.name)
    expect(page).not_to have_content(@product_oos.name)
  end

  it 'fitlers to display only out of stock products', js: true do
    select 'Out of Stock'
    expect(page).not_to have_content(@product_in_stock.name)
    expect(page).to have_content(@product_oos.name)
  end
end