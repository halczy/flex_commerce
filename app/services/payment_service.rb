class PaymentService
  attr_accessor :order

  def initialize(order_id: nil)
    @order = Order.find_by(id: order_id)
  end

  def create
    # build
    # validate order status
    # validate user fund by payment amount
  end

  def build
    # create payment with order info
  end

end
