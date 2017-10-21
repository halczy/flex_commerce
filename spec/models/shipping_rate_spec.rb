require 'rails_helper'

RSpec.describe ShippingRate, type: :model do

  let(:delivery_sa)   { FactoryBot.create(:delivery_sa) }
  let(:shipping_rate) { FactoryBot.create(:shipping_rate,
                                            shipping_method: delivery_sa) }

  describe 'creation' do
    it 'can be created' do
      expect(shipping_rate).to be_valid
    end
  end

end
