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

  def completed_tab?(params)
    'active' if (!params[:filter].present? || params[:filter] == 'service_process')
  end

  def pending_tab?(params)
    'active' if ( params[:filter] && params[:filter] == 'payment_process' )
  end

  def incomplete_tab?(params)
    'active' if ( params[:filter] && params[:filter] == 'creation_process' )
  end

  def display_mark_as_pickup_ready?(order)
    order.shipping_methods.self_pickup.present? &&
    order.status_before_type_cast >= 70 &&
    ( order.shipment.nil? || !order.shipment['pickup_readied_at'].present? )
  end

  def display_mark_as_pickup_completed?(order)
    order.shipment &&
    order.shipment['pickup_readied_at'].present? &&
    !order.shipment['pickup_completed_at'].present?
  end

  def display_ship_order?(order)
    order.shipping_methods.delivery.present? &&
    order.status_before_type_cast >= 70 &&
    ( order.shipment.nil? || !order.shipment['tracking_number'].present?)
  end

  def display_mark_as_shipping_completed?(order)
    order.shipment &&
    order.shipment['shipped_at'].present? &&
    !order.shipment['shipping_completed_at'].present?
  end

  def get_shipping_companies
    shipping_companies = []
    Order.all.each do |order|
      if order.shipment && order.shipment['shipping_company'].present?
        shipping_companies << order.shipment['shipping_company']
      end
    end
    shipping_companies.uniq
  end
end
