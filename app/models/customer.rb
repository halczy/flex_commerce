class Customer < User
  def total_spent
    qualified_orders = Order.where(user: self).where("status >= 60")
    qualified_orders.sum { |order| order.total }
  end

  def reward_income
    rewards = Transaction.all.select do |t|
      t.originable.try("reward?") &&
      t.processable == wallet
    end
    rewards.sum { |t| t.amount }
  end

  def monthly_reward_income
    rewards = Transaction.all.select do |t|
      t.originable.try("reward?") &&
      t.processable == wallet &&
      t.created_at.between?(Time.now.beginning_of_month, Time.now.end_of_month)
    end
    rewards.sum { |t| t.amount }
  end
end
