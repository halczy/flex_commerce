require 'rails_helper'

RSpec.describe ShippingRate, type: :model do

  let(:shipping_rate) { FactoryGirl.create(:shipping_rate) }

  describe 'creation' do
    it 'can be created' do
      expect(shipping_rate).to be_valid
    end

  end
end
