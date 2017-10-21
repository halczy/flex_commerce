require 'rails_helper'

RSpec.describe Categorization, type: :model do

  let(:product) { FactoryBot.create(:product) }
  let(:category) { FactoryBot.create(:category) }

  describe 'creation' do
    it 'can associate product with categories' do
      product.categorizations.create(category: FactoryBot.create(:category))
      product.categorizations.create(category: FactoryBot.create(:category))
      expect(product.categories.count).to eq(2)
    end

    it 'can associate category with products' do
      category.categorizations.create(product: FactoryBot.create(:product))
      category.categorizations.create(product: FactoryBot.create(:product))
      expect(category.products.count).to eq(2)
    end
  end

  describe 'validation' do
    it 'rejects duplicate relationship ' do
      cat_1 = category
      5.times { product.categorizations.create(category: cat_1) }
      expect(product.categories.count).to eq(1)
    end
  end


end
