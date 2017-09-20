require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do

  let(:payment_alipay)   { FactoryGirl.create(:payment, processor: 1) }

  before do |example|
    unless example.metadata[:skip_before]
      allow_any_instance_of(Alipay::Client).to receive(:verify?).and_return(true)
    end
  end

  describe 'GET alipay_return' do
    context 'with success params' do
      it 'saves returned params to payment_response' do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: payment_alipay.amount,
          out_trade_no: payment_alipay.id
        }

        expect(payment_alipay.reload.processor_response_return).to be_present
      end

      it 'confirms payment and order' do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: payment_alipay.amount,
          out_trade_no: payment_alipay.id
        }
        expect(payment_alipay.reload.client_side_confirmed?).to be_truthy
        expect(payment_alipay.order.payment_success?).to be_truthy
      end

      it 'redirects to order success page' do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: payment_alipay.amount,
          out_trade_no: payment_alipay.id
        }

        expect(response).to redirect_to(success_order_path(id: payment_alipay.order.id,
                                                           payment_id: payment_alipay.id))
      end
    end

    context 'with failure params' do
      it 'rejects unsigned params', skip_before: true do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: payment_alipay.amount,
          out_trade_no: payment_alipay.id
        }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to root_url
      end

      it 'returns false if amount paid is incorrect' do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: '0.01',
          out_trade_no: payment_alipay.id
        }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to root_url
      end

      it 'returns false if payment id is incorrect' do
        get :alipay_return, params: {
          id: payment_alipay,
          total_amount: payment_alipay.amount,
          out_trade_no: '65432147'
        }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'POST alipay_notify' do
  end
end
