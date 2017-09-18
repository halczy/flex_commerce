class PaymentService
  attr_accessor :order, :payment, :processor, :amount, :user

  def initialize(order_id: nil, payment_id: nil, processor: nil, amount: nil)
    @order = Order.find_by(id: order_id)
    @payment = Payment.find_by(id: payment_id)
    @processor = processor
    @amount = amount
    @user = set_user
  end

  def set_user
    if @order
      @order.user
    end
  end

  def create
    # build
    # validate order status
    # validate user fund by payment amount
  end

  def build
    variety = 0 if @order.confirmed?
    @amount = @order.total unless @amount.present?
    @payment = Payment.create!(order: @order,
                               processor: @processor,
                               variety: variety,
                               amount: @amount)
  end

  def validate_amount
    validate_amount_with_order
    validate_customer_fund if @pyament.processor == 'wallet'
  end

  private

    def validate_order_status
      return true if @order.confirmed?
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
