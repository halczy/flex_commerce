module TransactionsHelper

  def payment_source(transaction)
    if transaction.processable
      transaction.processable_type
    else
      transaction.originable.processor.titleize
    end
  end

  def amount_direction(wallet, transaction)
    transaction.processable == wallet ? 'Debit' : 'Credit'
  end

end
