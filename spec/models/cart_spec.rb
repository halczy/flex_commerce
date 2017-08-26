require 'rails_helper'

RSpec.describe Cart, type: :model do

  let(:cart) { FactoryGirl.create(:cart) }

  describe 'creation' do
    it 'can be created' do
      expect(cart).to be_valid
    end
  end


end
