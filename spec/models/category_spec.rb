require 'rails_helper'

RSpec.describe Category, type: :model do

  let(:cat) { FactoryGirl.create(:category) }

  describe 'creation' do
    it 'can be created with valid data' do
      expect(cat).to be_valid
    end

    context 'cannot create category with invalid information' do
      it 'cannot create a category without a name' do
        no_name_cat = FactoryGirl.build(:category, name: "")
        no_name_cat.valid?
        expect(no_name_cat.errors.messages[:name]).to include("can't be blank")
      end

      it 'cannot create a category with duplicate name' do
        FactoryGirl.create(:category, name: 'ABCD Cat')
        dup_cat = FactoryGirl.build(:category, name: 'ABCD Cat')
        dup_cat.valid?
        expect(dup_cat.errors.messages[:name]).to include('has already been taken')
      end
    end
  end

end
