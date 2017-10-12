module TransactionsHelper

  def payment_source(transaction)
    if transaction.processable
      transaction.processable_type
    else
      transaction.originable.processor.titleize
    end
  end

  def amount_direction(wallet, transaction)
    if transaction.originable.try(:charge?)
      'Debit'
    elsif transaction.originable.try(:reward?)
      'Credit'
    else
      transaction.processable == wallet ? 'Debit' : 'Credit'
    end
  end

end
