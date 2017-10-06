class TransferService
  attr_accessor :transfer, :transferer, :transferee, :amount,
                :fund_source, :fund_target, :processor, :status

  def initialize(transfer_id: nil, transferer_id: nil, transferee_id: nil, amount: nil)
    @transfer = Transfer.find_by(id: transfer_id)
    @transferer = @transfer.try(:transferer) || User.find_by(id: transferer_id)
    @transferee = @transfer.try(:transferee) || User.find_by(id: transferee_id)
    @amount = @transfer.try(:amount) || Money.new(amount.to_f * 100)
  end

  def create(processor: nil, fund_source: nil, fund_target: nil)
    begin
      @transfer = Transfer.create(
        transferer: @transferer,
        transferee: @transferee,
        amount: @amount,
        processor: (processor || 'wallet'),
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

  def transfer

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
      if @transfer.fund_source.available_fund < @amount
        raise(StandardError, 'Insufficient Fund')
      end
    end

end
