require 'rails_helper'

RSpec.describe Order, type: :model do

  let(:order)     { FactoryGirl.create(:order) }
  let(:new_order) { FactoryGirl.create(:new_order) }
  let(:order_pickup_selected) { FactoryGirl.create(:order_pickup_selected) }
  let(:order_delivery_selected) { FactoryGirl.create(:order_delivery_selected) }
  let(:order_mix_selected) { FactoryGirl.create(:order_mix_selected) }

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
        expect(new_order).to be_valid
        expect(new_order.inventories).not_to be_empty
      end
    end

    # context 'address' do
    #   it 'can have one address' do
    #     expect(new_order.address).to be_present
    #     expect(new_order.address.addressable).to eq(new_order)
    #   end
    # end

    context 'shipping methods' do
      it 'returns shipping methods used in order' do
        expect(order_mix_selected.shipping_methods.count).to eq(2)
      end
    end

    context 'product' do
      it 'returns product in order' do
        expect(new_order.products.first).to be_an_instance_of(Product)
      end

      it 'does not duplicate product returns' do
        expect(new_order.products.count).to eq(3)
      end

      context '#quantity' do
        it 'returns quantity of product inventories in order' do
          product = new_order.products.sample
          expect(new_order.quantity(product).count).to eq(1)
        end
      end
    end

    describe '#pick_up_address' do
      it 'returns the self pickup address' do
        expect(order_mix_selected.pick_up_address).to be_an_instance_of Address
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
        expect(order_mix_selected.shipping_method_mix).to eq('mix')
      end

      it 'returns false when inventories does not have shipping method' do
        expect(new_order.shipping_method_mix).to be_falsey
      end
    end

  end
end
