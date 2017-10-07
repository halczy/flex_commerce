FactoryGirl.define do
  factory :transfer do
    amount { Money.new(10000) }
    processor 'wallet'
    transferer { FactoryGirl.create(:wealthy_customer) }
    transferee { FactoryGirl.create(:customer) }

    transient do
      wallet_success false
    end

    after(:create) do |transfer, evaluator|
      if evaluator.wallet_success
        transfer.update(fund_target: transfer.transferee.wallet,
                        fund_source: transfer.transferer.wallet)
        TransferService.new(transfer_id: transfer.id).execute_transfer
      end
    end
  end
end
