module TransactionsHelper

  def payment_source(transaction)
    if transaction.processable
      transaction.processable_type
    else
      transaction.originable.processor.titleize
    end
  end

  def amount_direction(user, transaction)
    transaction.processable.user == user ? 'Debit' : 'Credit'
  end

end
