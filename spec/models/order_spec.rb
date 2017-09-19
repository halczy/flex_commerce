require 'rails_helper'

RSpec.describe Order, type: :model do

  let(:order)           { FactoryGirl.create(:order) }

  let(:order_selected)  { FactoryGirl.create(:order, selected: true) }
  let(:order_set)       { FactoryGirl.create(:order, set: true) }
  let(:order_confirmed) { FactoryGirl.create(:order, confirmed: true) }

  let(:order_pickup_selected)   { FactoryGirl.create(:order, selected: true,
                                                             only_pickup: true) }
  let(:order_pickup_set)        { FactoryGirl.create(:order, set: true,
                                                             only_pickup: true) }
  let(:order_delivery_selected) { FactoryGirl.create(:order, selected: true,
                                                             only_delivery: true) }
  let(:order_delivery_set)      { FactoryGirl.create(:order, set:true,
                                                             only_delivery: true) }
  let(:order_no_shipping_set)   { FactoryGirl.create(:order, set: true,
                                                             no_shipping: true) }

  let(:payment_wallet)   { FactoryGirl.create(:payment) }
  let(:payment_alipay)   { FactoryGirl.create(:payment, processor: 1) }

  let(:wallet_created)   { PaymentService.new(payment_id: payment_wallet.id) }
  let(:alipay_created)   { PaymentService.new(payment_id: payment_alipay.id) }

  describe 'creation' do
    it 'can be created' do
      expect(order).to be_valid
      expect(order.status).to eq('created')
    end

    context 'validation' do
      it 'cannot be created without user|customer' do
        expect {
          FactoryGirl.create(:order, user: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'relationships' do
    context 'inventory' do
      it 'can have inventories' do
        expect(order).to be_valid
        expect(order.inventories).not_to be_empty
      end
    end

    context 'address' do
      it 'can have one address' do
        expect(order_delivery_set.address).to be_present
        expect(order_delivery_set.address.addressable)
          .to eq(order_delivery_set)
      end
    end

    context 'shipping methods' do
      it 'returns shipping methods used in order' do
        expect(order_selected.shipping_methods.count).to eq(2)
      end
    end

    context 'product' do
      it 'returns product in order' do
        expect(order.products.first).to be_an_instance_of(Product)
      end

      it 'does not duplicate product returns' do
        expect(order.products.count).to eq(3)
      end

      context '#inventories_by' do
        it 'returns product inventories in order' do
          product = order.products.sample
          expect(order.inventories_by(product).count).to eq(1)
        end
      end
    end

  end

  describe '#pick_up_address' do
    it 'returns the self pickup address' do
      expect(order_selected.pick_up_address).to be_an_instance_of Address
    end
  end

  describe '#shipping_method_mix' do
    it 'returns self_pickup when all inventories are marked for self pickup' do
      expect(order_pickup_selected.shipping_method_mix).to eq('self_pickup')
    end

    it 'returns delivery when all inventories are marked for delivery' do
      expect(order_delivery_selected.shipping_method_mix).to eq('delivery')
    end

    it 'reutrns mix when inventories have mixed shipping method' do
      expect(order_selected.shipping_method_mix).to eq('mix')
    end

    it 'returns false when inventories does not have shipping method' do
      expect(order.shipping_method_mix).to be_falsey
    end
  end

  describe 'pre_confirm_total' do
    it 'returns order total cost' do
      result = order_set.pre_confirm_total
      order_service = OrderService.new(order_id: order_set)
      order_service.confirm
      expect(result).to eq(order_set.reload.total)
    end

    it 'does not require to be confirmed to confrims order' do
      result = order_set.pre_confirm_total
      expect(result).to be > 0
      expect(order_set.reload.status).to eq('shipping_confirmed')
    end
  end

  describe '#total' do
    it 'reutrns inventories and shipping cost' do
      order_service = OrderService.new(order_id: order_set)
      order_service.confirm
      order_total = order_service.total_shipping_cost +
                    order_service.total_inventories_cost
      expect(order_set.reload.total).to eq(order_total)
    end

    it 'returns false if order is not confrimed' do
      expect(order_delivery_set.total).to be_falsey
    end
  end

  describe '#amount paid' do
    it 'reutrns zero is no confrimed payment is available' do
      expect(order_confirmed.amount_paid).to eq(0)
    end

    it 'returns the partial amount paid' do
      payment = FactoryGirl.create(:payment, order: order_confirmed,
                                             amount: Money.new(100))
      service = PaymentService.new(payment_id: payment.id)
      service.user.wallet.update(balance: 9999999)
      service.charge
      expect(order_confirmed.reload.amount_paid).to eq(Money.new(100))
    end

    it 'returns the full amount paid' do
      wallet_created.user.wallet.update(balance: wallet_created.amount)
      wallet_created.charge
      expect(wallet_created.order.amount_paid).to eq(wallet_created.order.total)
    end
  end

  describe '#amount_unpaid' do
    it 'returns order total if no payment exist' do
      expect(order_confirmed.amount_unpaid).to eq(order_confirmed.total)
    end

    it 'returns unpaid balance if partial payment exist' do
      payment = FactoryGirl.create(:payment, order: order_confirmed,
                                             amount: Money.new(100))
      service = PaymentService.new(payment_id: payment.id)
      service.user.wallet.update(balance: 9999999)
      service.charge
      expected_unpaid = order_confirmed.total - Money.new(100)
      expect(order_confirmed.reload.amount_unpaid).to eq(expected_unpaid)
    end

    it 'returns zero if order is paid in full' do
      wallet_created.user.wallet.update(balance: wallet_created.amount)
      wallet_created.charge
      expect(wallet_created.order.amount_unpaid).to eq(0)
    end
  end
end
