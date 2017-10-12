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
end
