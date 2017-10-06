class TransferService
  attr_accessor :transfer, :transferer, :transferee, :amount

  def initialize(transfer_id: nil, transferer_id: nil, transferee_id: nil, amount: nil)
    @transfer = Transfer.find_by(id: transfer_id)
    @transferer = @transfer.try(:transferer) || User.find_by(id: transferer_id)
    @transferee = @transfer.try(:transferee) || User.find_by(id: transferee_id)
    @amount = @transfer.try(:amount) || Money.new(amount.to_f * 100)
  end
end
