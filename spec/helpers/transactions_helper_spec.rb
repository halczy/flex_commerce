require 'rails_helper'

RSpec.describe TransactionsHelper, type: :helper do

  let(:completed_order) { FactoryGirl.create(:service_order, completed: true)}

  before do

    @wallet_transaction =  Transaction.create(amount: completed_order.total,
                                              originable: completed_order.payments.first,
                                              transactable: completed_order,
                                              processable: completed_order.user.wallet)
  end
  
  describe '#payment_source' do
    it "returns source via processable type if it exists" do
      wallet_transaction =  Transaction.create(amount: completed_order.total,
                                               originable: completed_order.payments.first,
                                               transactable: completed_order,
                                               processable: completed_order.user.wallet)
      expect(helper.payment_source(wallet_transaction)).to eq('Wallet') 
    end
    
    it "returns source via payment" do
      completed_order.payments.first.alipay!
      alipay_transaction =  Transaction.create(amount: completed_order.total,
                                               originable: completed_order.payments.first,
                                               transactable: completed_order)      
      expect(helper.payment_source(alipay_transaction)).to eq('Alipay')
    end
  end

end