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
      I18n.t 'debit'
    elsif transaction.originable.try(:reward?)
      I18n.t 'credit'
    else
      transaction.processable == wallet ? I18n.t('debit') : I18n.t('credit')
    end
  end

end
