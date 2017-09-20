require 'rails_helper'

RSpec.describe PaymentService, type: :model do

  let(:wealthy_customer) { FactoryGirl.create(:wealthy_customer) }
  let(:order_set)        { FactoryGirl.create(:order, set: true) }
  let(:order_confirmed)  { FactoryGirl.create(:order, confirmed: true) }
  let(:payment_wallet)   { FactoryGirl.create(:payment) }
  let(:payment_alipay)   { FactoryGirl.create(:payment, processor: 1) }

  let(:wallet_created)   { PaymentService.new(payment_id: payment_wallet.id) }
  let(:alipay_created)   { PaymentService.new(payment_id: payment_alipay.id) }

  describe 'create payment' do
    describe '#validate_order_status' do
      it 'returns true if order is confirmed' do
        payment_service = PaymentService.new(order_id: order_confirmed.id)
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
        payment_service = PaymentService.new(order_id: order_confirmed.id,
                                             processor: 'wallet',
                                             amount: Money.new(100))
        payment_service.build
        expect(payment_service.payment).to be_present
        expect(payment_service.payment.variety).to eq('charge')
        expect(payment_service.payment.amount).to eq(Money.new(100))
        expect(payment_service.payment.status).to eq('created')
        expect(payment_service.payment.order).to eq(order_confirmed)
      end

      it 'defaults amount to the order amount is the figure is not given' do
        payment_service = PaymentService.new(order_id: order_confirmed.id,
                                             processor: 'wallet')
        payment_service.build
        expect(payment_service.payment.amount).to eq(order_confirmed.total)
      end

      it 'does not create payment if processor is missing' do
        payment_service = PaymentService.new(order_id: order_confirmed.id,
                                             amount: Money.new(100))
        expect { payment_service.build }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe '#set_user' do
      it 'returns user if order is present' do
        payment_service = PaymentService.new(order_id: order_confirmed.id)
        expect(payment_service.user).to be_present
      end
    end

    describe '#validate_amount_with_order' do
      it 'returns true if payment amount is within order total' do
        payment_service = PaymentService.new(order_id: order_confirmed.id,
                                             processor: 'wallet',
                                             amount: Money.new(100))
        payment_service.build
        expect(payment_service.send(:validate_amount_with_order)).to be_truthy
      end

      it 'raises error if payment amount exceeds order total' do
        payment_service = PaymentService.new(order_id: order_confirmed.id,
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
        payment_service = PaymentService.new(order_id: order_confirmed.id,
                                                       processor: 'wallet')
        payment_service.build
        expect {
          payment_service.send(:validate_customer_fund)
        }.to raise_error(StandardError)
      end
    end

    describe '#create' do
      context 'with validate arguments' do
        it 'creates wallet payment' do
          order = FactoryGirl.create(:order, confirmed: true, user: wealthy_customer)
          payment_service = PaymentService.new(order_id: order, processor: 'wallet')
          result = payment_service.create
          expect(result).to be_an_instance_of(Payment)
          expect(result.status).to eq('created')
          expect(result.order).to eq(order)
          expect(result.order.status).to eq('payment_pending')
        end

        it 'creates alipay payment' do

        end
      end

      context 'with invalid arguments' do
        it 'does not create payment with unconfirmed order' do
          payment_service = PaymentService.new(order_id: order_set)
          expect(payment_service.create).to be_falsey
        end

        it 'does not create wallet payment when user does not have sufficient fund' do
          payment_service = PaymentService.new(order_id: order_confirmed,
                                               processor: 'wallet')
          expect(payment_service.create).to be_falsey
        end
      end
    end
  end

  describe 'charge payment' do
    describe '#mark_success' do
      it 'updates payment status' do
        wallet_created.user.wallet.update(balance: wallet_created.amount)
        wallet_created.charge_wallet
        expect(wallet_created.payment.status).to eq('processor_confirmed')
      end

      it 'logs a transaction' do
        wallet_created.user.wallet.update(balance: wallet_created.amount)
        expect {
          wallet_created.charge_wallet
        }.to change(Transaction, :count).by(1)
        transaction = wallet_created.payment.transaction_log
        expect(transaction.transactable).to eq(wallet_created.order)
        expect(transaction.processable).to eq(wallet_created.user.wallet)
      end
    end

    describe '#mark_failure' do
      it 'updates payment status' do
        wallet_created.charge_wallet
        expect(wallet_created.payment.status).to eq('insufficient_fund')
      end
    end

    describe '#charge_wallet' do
      it 'returns true if it debit customer wallet successfully' do
        wallet_created.user.wallet.update(balance: wallet_created.amount)
        expect(wallet_created.charge_wallet).to be_truthy
        expect(wallet_created.user.reload.wallet.balance).to eq(0)
      end

      context 'failing condition' do
        it 'returns false if customer does not have sufficient fund' do
          expect(wallet_created.charge_wallet).to be_falsey
        end
      end
    end

    describe '#order_paid_in_full?' do
      before do
        order_confirmed.user.wallet.update(balance: 9999999999)
        total_minus_1 = order_confirmed.total - Money.new(100)
        @payment_1 = FactoryGirl.create(:payment, order: order_confirmed,
                                                  amount: total_minus_1)
        @payment_2 = FactoryGirl.create(:payment, order: order_confirmed,
                                                  amount: Money.new(100))
      end

      it 'returns true if order is paid in full' do
        service_1 = PaymentService.new(payment_id: @payment_1.id)
        service_2 = PaymentService.new(payment_id: @payment_2.id)
        service_1.charge_wallet
        expect(service_1.order_paid_in_full?).to be_falsey
        service_2.charge_wallet
        expect(service_2.order_paid_in_full?).to be_truthy
      end
    end

    describe '#process_result' do
      it 'sets order status to payment success if order paid in full' do
        wallet_created.user.wallet.update(balance: wallet_created.amount)
        wallet_created.charge_wallet
        expect(wallet_created.order.payment_success?).to be_truthy
      end

      it 'sets order status to partial payment if some amount paid' do
        payment = FactoryGirl.create(:payment, order: order_confirmed,
                                               amount: Money.new(100))
        payment.order.user.wallet.update(balance: 9999999)
        payment_service = PaymentService.new(payment_id: payment.id)
        payment_service.charge_wallet
        expect(payment_service.order.partial_payment?).to be_truthy
      end

      it 'sets order status to failure if payment fails no other payment exist' do
        wallet_created.charge_wallet
        expect(wallet_created.order.payment_fail?).to be_truthy
      end
    end

    describe '#charge' do
      it 'returns true if charge is successfully' do
        wallet_created.user.wallet.update(balance: wallet_created.amount)
        expect(wallet_created.charge).to be_truthy
        expect(wallet_created.payment.processor_confirmed?).to be_truthy
        expect(wallet_created.order.payment_success?).to be_truthy
      end

      it 'returns false if charge fail' do
        expect(wallet_created.charge).to be_falsey
        expect(wallet_created.payment.insufficient_fund?).to be_truthy
        expect(wallet_created.order.payment_fail?).to be_truthy
      end
    end
  end
end
