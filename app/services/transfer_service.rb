class TransferService
  attr_accessor :transfer, :transferer, :transferee, :amount,
                :fund_source, :fund_target, :processor, :status

  def initialize(transfer_id: nil, transferer_id: nil, transferee_id: nil,
                 amount: nil, processor: nil)
    @transfer = Transfer.find_by(id: transfer_id)
    @transferer = @transfer.try(:transferer) || User.find_by(id: transferer_id)
    @transferee = @transfer.try(:transferee) || User.find_by(id: transferee_id)
    @amount = @transfer.try(:amount) || amount.to_money
    @processor = processor || @transfer.try(:processor) || 'wallet'
  end

  def create(fund_source: nil, fund_target: nil)
    case @processor
    when 'wallet'
      create_internal_transfer(fund_source: fund_source, fund_target: fund_target)
    when 'bank'
      create_external_transfer
    when 'alipay'
      create_external_transfer
    end
  end

  def create_internal_transfer(fund_source: nil, fund_target: nil)
    begin
      Transfer.transaction do
        @transfer = Transfer.create(
          transferer: @transferer,
          transferee: @transferee,
          amount: @amount,
          processor: 'wallet',
          fund_source: (fund_source || @transferer.wallet),
          fund_target: (fund_target || @transferee.wallet)
        )
        validate_internal_transferee
        validate_funding
        true
      end
    rescue Exception
      false
    end
  end

  def create_external_transfer
    begin
      Transfer.transaction do
        @transfer = Transfer.create(
          transferer: @transferer,
          transferee: @transferee,
          amount: @amount,
          processor: @processor,
          fund_source: @transferer.wallet
        )
        validate_external_transferee
        validate_funding
        withhold_fund
        true
      end
    rescue Exception
      false
    end
  end

  def execute_transfer
    case @transfer.processor
    when 'wallet' then wallet_transfer
    when 'bank'   then bank_transfer
    end
  end

  def wallet_transfer
    begin
      Transfer.transaction do
        validate_internal_transferee
        validate_funding
        @transfer.fund_source.debit(@transfer.amount)
        @transfer.fund_target.credit(@transfer.amount)
        process_wallet_transfer
        true
      end
    rescue Exception
      false
    end
  end

  def bank_transfer
    begin
      Transfer.transaction do
        @transfer.fund_source.withdraw(@amount)
        @transfer.transaction_log.update(
          note: "SUCCESS: Withdraw to bank account."
        )
        @transfer.success!
        true
      end
    rescue Exception
      false
    end
  end

  def cancel_transfer
    case @processor
    when 'bank' then cancel_bank_transfer
    end
  end

  def cancel_bank_transfer
    begin
      Transfer.transaction do
        @transfer.fund_source.cancel_withdraw(@amount)
        @transfer.failure!
        @transfer.transaction_log.update(
          amount: 0,
          note: 'REJECTED: Withdraw request rejected.'
        )
        true
      end
    rescue Exception
      false
    end
  end

  private

    def validate_internal_transferee
      if @transfer.transferer == @transfer.transferee
        raise(StandardError, 'Cannot transfer fund to your own account.')
      end
    end

    def validate_external_transferee
      if @transfer.transferer != @transfer.transferee
        raise(StandardError, 'You cannot transfer to other customer.')
      end
    end

    def validate_funding
      return true if @transfer.alipay?
      if @transfer.amount == 0
        raise(StandardError, 'Invalid Amount')
      end
      if @transfer.fund_source.available_fund < @transfer.amount
        raise(StandardError, 'Insufficient Fund')
      end
    end

    def process_wallet_transfer
      @transfer.success!
      Transaction.create(
        amount: @transfer.amount,
        transactable: @transfer,
        originable: @transfer.fund_target,
        processable: @transfer.fund_source,
        note: "Transfer from #{@transferer.name} to #{@transferee.name}"
      )
    end

    def withhold_fund
      @transfer.fund_source.create_withdraw(@amount)
      @transfer.pending!
      Transaction.create(
        amount: @transfer.amount,
        transactable: @transfer,
        originable: @transfer.fund_source,
        processable: @transfer.fund_source,
        note: "PENDING: Withdraw to bank account."
      )
    end
end
