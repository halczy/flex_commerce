class Customer < User

  def total_spent
    qualified_orders = Order.where(user: self).where("status >= 60")
    qualified_orders.sum { |order| order.total }
  end
end
