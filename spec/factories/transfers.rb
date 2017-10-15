FactoryGirl.define do
  factory :wallet_transfer, class: Transfer do
    amount { Money.new(10000) }
    processor 'wallet'
    transferer { FactoryGirl.create(:wealthy_customer) }
    transferee { FactoryGirl.create(:customer) }

    transient do
      success false
    end

    after(:create) do |transfer, evaluator|
      if evaluator.success
        transfer.update(fund_target: transfer.transferee.wallet,
                        fund_source: transfer.transferer.wallet)
        TransferService.new(transfer_id: transfer.id).execute_transfer
      end
    end
  end

  factory :bank_transfer, class: Transfer do
    amount { Money.new(10000) }
    processor 'bank'
    transferer { FactoryGirl.create(:wealthy_customer) }
    transferee { transferer }
    fund_target { transferer.wallet }
    fund_source { transferer.wallet }

    transient do
      success false
    end

    after(:create) do |transfer, evaluator|
      if evaluator.success
        Transaction.create(
          amount: 100.to_money,
          transactable: transfer,
          originable: transfer.fund_source,
          processable: transfer.fund_source,
          note: "PENDING: Withdraw to bank account."
        )
        transfer.transferer.wallet.update(pending: 100.to_money)
        TransferService.new(transfer_id: transfer.id).execute_transfer
      end
    end
  end

  factory :alipay_transfer, class: Transfer do
    amount { Money.new(10000) }
    processor 'alipay'
    transferer { FactoryGirl.create(:wealthy_customer) }
    transferee { transferer }
    fund_target { transferer.wallet }
    fund_source { transferer.wallet }

    transient do
      success false
    end

    after(:create) do |transfer, evaluator|
      if evaluator.success
        Transaction.create(
          amount: 100.to_money,
          transactable: transfer,
          originable: transfer.fund_source,
          processable: transfer.fund_source,
          note: "PENDING: Withdraw to Alipay account."
        )
        transfer.transferer.wallet.update(pending: 100.to_money)
        ts = TransferService.new(transfer_id: transfer.id)
        ts.manual_alipay_transfer
      end
    end
  end
end
