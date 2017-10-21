require 'rails_helper'

describe 'menu', type: :feature do
  before do
    @cat_1 = FactoryBot.create(:category, display_order: 0)
    @cat_2 = FactoryBot.create(:category, display_order: 2)
    @cat_3 = FactoryBot.create(:category, display_order: 1)
  end

  it 'displays parent categories on navbar' do
    visit root_path
    expect(page).to have_content(@cat_1.name)
    expect(page).to have_content(@cat_2.name)
    expect(page).to have_content(@cat_3.name)
  end

  it 'displays parent categories in order' do
    visit root_path
    expect(page).to have_content("#{@cat_1.name} #{@cat_3.name} #{@cat_2.name}")
  end

  context 'child categories' do
    before do
      @child_cat_1 = FactoryBot.create(:category, parent_id: @cat_2, display_order: 2)
      @child_cat_2 = FactoryBot.create(:category, parent_id: @cat_2, display_order: 1)
    end

    it 'displays on dropdown' do
      visit root_path

      expect(page).to have_content(@child_cat_1.name)
      expect(page).to have_content(@child_cat_2.name)
    end

    it 'dispalys in order' do
      visit root_path

      expect(page).to have_content(
        "#{@child_cat_2.name} #{@cat_2.name} #{@child_cat_1.name}"
      )
    end
  end
end

describe 'brand' do
  before do
    @brand_1 = FactoryBot.create(:brand, display_order: 0)
    @brand_2 = FactoryBot.create(:brand, display_order: 2)
    @brand_3 = FactoryBot.create(:brand, display_order: 1)
  end

  it 'displays brands' do
    visit root_path

    expect(page).to have_content(@brand_1.name)
    expect(page).to have_content(@brand_2.name)
    expect(page).to have_content(@brand_3.name)
  end

  it 'displays brands in order' do
    visit root_path

    expect(page).to have_content(
      "#{@brand_1.name} #{@brand_3.name} #{@brand_2.name}"
    )
  end
end
