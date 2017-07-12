require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CategoriesHelper. For example:
#
# describe CategoriesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CategoriesHelper, type: :helper do
  describe '#parent_count' do

    before do
      @top_cat = FactoryGirl.create(:category)
      @child_cat_1 = FactoryGirl.create(:category, parent: @top_cat)
      @child_cat_2 = FactoryGirl.create(:category, parent: @child_cat_1)
      @child_cat_3 = FactoryGirl.create(:category, parent: @child_cat_2)
      @child_cat_4 = FactoryGirl.create(:category, parent: @child_cat_3)
    end

    it 'returns the parent count' do
      expect(helper.parent_count(@child_cat_1)).to eq(1)
      expect(helper.parent_count(@child_cat_4)).to eq(4)
    end

    it 'returns zero when category has no parent' do
      expect(helper.parent_count(@top_cat)).to eq(0)
    end
  end
end
