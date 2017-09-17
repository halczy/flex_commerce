module OrdersHelper

  def subtotal_by(order, product)
    invs = order.inventories_by(product)
    case order.status
    when 'confirmed'
      invs.sum { |i| i.purchase_price }
    else
      invs.sum { |i| i.product.price_member }
    end
  end

  def shipping_method_by(order, product)
    invs = order.inventories_by(product)
    invs.sample.shipping_method.variety
  end

  def purchase_price_by(order, product)
    invs = order.inventories_by(product)
    invs.sample.purchase_price
  end

  def get_delivery_method(order)
    order.shipping_methods.select { |m| m.variety == 'delivery' }.first
  end

  def get_self_pickup_method(order)
    order.shipping_methods.select { |m| m.variety == 'self_pickup' }.first
  end

end
