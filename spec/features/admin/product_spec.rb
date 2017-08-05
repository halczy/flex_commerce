require 'rails_helper'

describe 'Admin Dashboard - Product', type: :feature do

  let(:admin) { FactoryGirl.create(:admin) }
  before { feature_signin_as(admin) }

  describe 'create' do
    it 'can create product'
    it 'can create product with categories'
    it 'can create product with images attached'

    context 'with invalid data' do
      it 'cannot create product with empty fields'
    end
  end

  describe 'edit' do
    it 'can edit product'
    it 'can reassgin categories'
    it 'can attach new images'
    it 'can edit existing image properties'
  end

  describe 'delete' do
    it 'can delete product'
    it 'removes categories associations when product is removed'
    it 'removes associated images when product is deleted'
  end
end
