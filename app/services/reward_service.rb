class RewardService
  attr_accessor :order, :referral_amount, :cash_back_amount

  def initialize(order_id: nil)
    @order = Order.find(order_id)
    @referral_amount = Money.new(0)
    @cash_back_amount = Money.new(0)
  end

  def distribute
    # CALCUATE REWARD AMOUNTS FOR ALL REWARD METHODS
    @order.inventories.each do |inv|
      inv.product.reward_methods.each do |reward_method|
        reward_amount(inv, reward_method)
      end
    end
    # CALL PRESET SUB DISTRIBUTE METHODS
    distribute_referral if referral_rewardable?
    distribute_cash_back if cash_back_rewardable?
  end

  def reward_amount(inv, reward_method)
    case reward_method.variety
    when 'referral'  then referral_reward_amount(inv, reward_method)
    when 'cash_back' then cash_back_reward_amount(inv, reward_method)
    end
  end

  def distribute_referral
    payment_service = PaymentService.new(
      order_id: @order.id,
      amount: @referral_amount,
      user_id: @order.user.referer.id,
      variety: 'reward'
    )
    payment_service.create
    payment_service.reward
    note = "Referral reward from #{@order.user.name}."
    payment_service.payment.reload.transaction_log.update(note: note)
  end

  def distribute_cash_back
    reward_target = @order.user.total_spent > 0 ? @order.user : @order.user.referer
    payment_service = PaymentService.new(
      order_id: @order.id,
      amount: @cash_back_amount,
      user_id: reward_target.id,
      variety: 'reward'
    )
    payment_service.create
    payment_service.reward
    note = "Cash back reward from #{reward_target.name}."
    payment_service.payment.reload.transaction_log.update(note: note)
  end

  private

    def referral_reward_amount(inv, reward_method)
      percentage = reward_method.reload.percentage.to_f * 0.01
      @referral_amount += inv.product.price_reward * percentage
    end

    def cash_back_reward_amount(inv, reward_method)
      percentage = reward_method.reload.percentage.to_f * 0.01
      @cash_back_amount += inv.product.price_reward * percentage
    end

    def referral_rewardable?
      return false unless @order.user.referer
      return false unless @referral_amount > 0
      true
    end

    def cash_back_rewardable?
      return false unless @order.user.referer
      return false unless @cash_back_amount > 0
      true
    end


end
