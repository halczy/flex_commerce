module OrdersHelper

  def subtotal_by(order, product)
    invs = order.inventories_by(product)
    subtotal = invs.sum { |i| i.purchase_price }
  end

  def shipping_method_by(order, product)
    invs = order.inventories_by(product)
    invs.sample.shipping_method.variety
  end

end
