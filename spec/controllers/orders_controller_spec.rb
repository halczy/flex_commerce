require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:customer)  { FactoryGirl.create(:customer) }
  let(:cart)      { FactoryGirl.create(:cart) }
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:new_order) { FactoryGirl.create(:new_order) }

  describe 'POST create' do

  end

  describe 'GET select_shipping' do
    it 'response successfully' do
      get :select_shipping, params: { id: new_order.id }
      expect(response).to be_success
    end
  end

end
