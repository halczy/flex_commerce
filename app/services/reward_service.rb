class RewardService
  attr_accessor :order

  def initialize(order_id: nil)
    @order = Order.find(order_id)
  end

  def distribute

  end

end
