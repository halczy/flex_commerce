class TransferService
  attr_accessor :transfer, :transferer, :transferee, :amount,
                :fund_source, :fund_target, :processor, :status

  def initialize(transfer_id: nil, transferer_id: nil, transferee_id: nil,
                 amount: nil, processor: nil)
    @transfer = Transfer.find_by(id: transfer_id)
    @transferer = @transfer.try(:transferer) || User.find_by(id: transferer_id)
    @transferee = @transfer.try(:transferee) || User.find_by(id: transferee_id)
    @amount = @transfer.try(:amount) || Money.new(amount.to_f * 100)
    @processor = processor || 'wallet'
  end

  def create(fund_source: nil, fund_target: nil)
    case @processor
    when 'wallet'
      create_wallet_transfer(fund_source: fund_source, fund_target: fund_target)
    end
  end

  def create_wallet_transfer(fund_source: nil, fund_target: nil)
    begin
      @transfer = Transfer.create(
        transferer: @transferer,
        transferee: @transferee,
        amount: @amount,
        processor: 'wallet',
        fund_source: (fund_source || @transferer.wallet),
        fund_target: (fund_target || @transferee.wallet)
      )
      validate_transferee
      validate_funding
      true
    rescue Exception
      false
    end
  end

  def execute_transfer
    case @transfer.processor
    when 'wallet' then wallet_transfer
    end
  end

  def wallet_transfer
    begin
      validate_transferee
      validate_funding
      @transfer.fund_source.debit(@transfer.amount)
      @transfer.fund_target.credit(@transfer.amount)
      process_wallet_transfer
      true
    rescue Exception
      false
    end
  end

  private

    def validate_transferee
      if @transfer.transferer == @transfer.transferee
        raise(StandardError, 'Cannot transfer fund to your own account')
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
end
