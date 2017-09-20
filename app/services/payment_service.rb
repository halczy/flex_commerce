class PaymentService
  attr_accessor :order, :payment, :processor, :amount, :user

  def initialize(order_id: nil, payment_id: nil, processor: nil, amount: nil)
    @payment = Payment.find_by(id: payment_id)
    @order = Order.find_by(id: order_id) || @payment.order
    @processor = processor
    @amount = amount || @payment.try(:amount) || @order.try(:total)
    @user = @order.user
  end

  def validate_amount
    validate_amount_with_order
    validate_customer_fund if @payment.processor == 'wallet'
  end

  def build
    variety = 0 if @order.status_before_type_cast.between?(20, 59)
    @amount = @order.total unless @amount.present?
    @payment = Payment.create!(order: @order,
                               processor: @processor,
                               variety: variety,
                               amount: @amount)
  end

  def create
    begin
      Payment.transaction do
        build
        validate_order_status
        validate_amount
        @order.payment_pending!
        @payment
      end
    rescue Exception
      @payment = nil
      false
    end
  end

  def mark_success
    @payment.processor_confirmed!
    Transaction.create(amount: @amount, originable: @payment,
                                        transactable: @order,
                                        processable: @user.wallet)
  end

  def mark_failure
    @payment.insufficient_fund!
  end

  def process_result
    if order_paid_in_full?
      @order.payment_success!
    elsif @payment.client_side_confirmed? || @payment.processor_confirmed?
      @order.partial_payment!
    else
      @order.payment_fail! unless @order.partial_payment?
    end
  end

  def order_paid_in_full?
    payment_total = @order.amount_paid
    payment_total == @order.total
  end

  def charge_wallet
    begin
      Payment.transaction do
        validate_customer_fund
        @user.wallet.debit(@amount)
        @payment.update(amount: @amount)
        mark_success
        process_result
        true
      end
    rescue Exception
      mark_failure
      process_result
      false
    end
  end

  def create_alipay
  end

  def charge
    case @payment.processor
    when 'wallet' then charge_wallet
    when 'alipay' then charge_alipay
    end
  end

  private

    def validate_order_status
      return true if @order.status_before_type_cast.between?(20, 59)
      raise(StandardError, 'Invalid order status.')
    end

    def validate_amount_with_order
      return true if @payment.amount <= @order.total
      raise(StandardError, 'Payment amount cannot exceed order total.')
    end

    def validate_customer_fund
      return true if @user.wallet.sufficient_fund?(@payment.amount)
      raise(StandardError, 'Insufficient fund')
    end
end
