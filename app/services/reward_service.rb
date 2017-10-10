class RewardService
  attr_accessor :order, :referral_amount

  def initialize(order_id: nil)
    @order = Order.find(order_id)
    @referral_amount = Money.new(0)
  end

  def distribute
    # CALCUATE REWARD AMOUNTS FOR ALL REWARD METHODS
    @order.inventories.each do |inv|
      inv.product.reward_methods.each do |reward_method|
        reward_amount(inv, reward_method)
      end
    end
    # CALL PRESET SUB DISTRIBUTE METHODS
  end

  def distribute_referral
    # GET REFERER
    # DEPOSIT VIA PAYMENT SERVICE
  end

  def reward_amount(inv, reward_method)
    case reward_method.variety
    when 'referral' then referral_reward_amount(inv, reward_method)
    end
  end

  private

    def referral_reward_amount(inv, reward_method)
      percentage = reward_method.reload.percentage.to_f * 0.01
      @referral_amount += inv.product.price_reward * percentage
    end


end
