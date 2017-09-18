require 'rails_helper'

RSpec.describe PaymentService, type: :model do

  let(:wealthy_customer) { FactoryGirl.create(:wealthy_customer) }
  let(:order_set)       { FactoryGirl.create(:order, set: true) }
  let(:order_confrimed) { FactoryGirl.create(:order, confirmed: true) }

  describe 'create wallet payment' do
    describe '#validate_order_status' do
      it 'returns true if order is confirmed' do
        payment_service = PaymentService.new(order_id: order_confrimed.id)
        expect(payment_service.send(:validate_order_status)).to be_truthy
      end

      it 'returns raise error is order is not confirmed' do
        payment_service = PaymentService.new(order_id: order_set.id)
        expect {
          payment_service.send(:validate_order_status)
        }.to raise_error(StandardError)
      end
    end

    describe '#build' do
      it 'creates payment for confirmed order' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                             processor: 'wallet',
                                             amount: Money.new(100))
        payment_service.build
        expect(payment_service.payment).to be_present
        expect(payment_service.payment.variety).to eq('charge')
        expect(payment_service.payment.amount).to eq(Money.new(100))
        expect(payment_service.payment.status).to eq('created')
        expect(payment_service.payment.order).to eq(order_confrimed)
      end

      it 'defaults amount to the order amount is the figure is not given' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                             processor: 'wallet')
        payment_service.build
        expect(payment_service.payment.amount).to eq(order_confrimed.total)
      end

      it 'does not create payment if processor is missing' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                             amount: Money.new(100))
        expect { payment_service.build }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe '#set_user' do
      it 'returns user if order is present' do
        payment_service = PaymentService.new(order_id: order_confrimed.id)
        expect(payment_service.user).to be_present
      end
    end

    describe '#validate_amount_with_order' do
      it 'returns true if payment amount is within order total' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                             processor: 'wallet',
                                             amount: Money.new(100))
        payment_service.build
        expect(payment_service.send(:validate_amount_with_order)).to be_truthy
      end

      it 'raises error if payment amount exceeds order total' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                             processor: 'wallet',
                                             amount: Money.new(9999999))
        payment_service.build
        expect {
          payment_service.send(:validate_amount_with_order)
        }.to raise_error(StandardError)
      end
    end

    describe '#validate_customer_fund' do
      it 'returns true if customer have sufficient fund to complete order' do
        order = FactoryGirl.create(:order, confirmed: true, user: wealthy_customer)
        payment_service = PaymentService.new(order_id: order, processor: 'wallet')
        payment_service.build
        expect(payment_service.send(:validate_customer_fund)).to be_truthy
      end

      it 'raises error if customer does not have enough fund to make the payment' do
        payment_service = PaymentService.new(order_id: order_confrimed.id,
                                                       processor: 'wallet')
        payment_service.build
        expect {
          payment_service.send(:validate_customer_fund)
        }.to raise_error(StandardError)
      end
    end
  end
end
