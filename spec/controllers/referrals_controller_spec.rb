require 'rails_helper'

RSpec.describe ReferralsController, type: :controller do

  let(:customer) { FactoryBot.create(:customer) }

  describe 'GET set_referral' do
    context 'with valid params' do
      it 'sets referer param by eamil' do
        get :set_referral, params: { id: customer.email }
        expect(response).to redirect_to(signup_path(referer_id: customer.id))
      end

      it 'sets referer param by cell number' do
        get :set_referral, params: { id: customer.cell_number }
        expect(response).to redirect_to(signup_path(referer_id: customer.id))
      end

      it 'sets referer param by member id' do
        get :set_referral, params: { id: customer.member_id }
        expect(response).to redirect_to(signup_path(referer_id: customer.id))
      end

      it 'sets referer params by id' do
        get :set_referral, params: { id: customer.id }
        expect(response).to redirect_to(signup_path(referer_id: customer.id))
      end
    end

    context 'with invalid params' do
      it 'flash warning message when referer is not found' do
        get :set_referral, params: { id: 'random_string' }
        expect(response).to redirect_to(signup_path)
        expect(flash[:warning]).to be_present
      end
    end
  end
end
