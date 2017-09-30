class OrderService
  attr_accessor :order, :cart

  def initialize(order_id: nil, cart_id: nil)
    @order = Order.find_by(id: order_id)
    @cart = Cart.find_by(id: cart_id)
  end

  def create
    begin
      Order.transaction do
        build
        transfer_inventories
        @order
      end
    rescue Exception
      @order = nil
      false
    end
  end

  def build
    @order = Order.create!(user: @cart.user)
  end

  def transfer_inventories
    raise('Cart is empty') if @cart.inventories.empty?
    @cart.inventories.tap do |inv|
      inv.update(cart_id: nil, order_id: @order.id, status: 2)
    end
  end

  def set_shipping(product_params)
    return false unless product_params.present?
    product_params.each do |key, value|
      shipping_method = ShippingMethod.find_by(id: value['shipping_methods'])
      product = Product.find_by(id: value['id'])
      set_shipping_method(product, shipping_method)
    end
  end

  def get_inventories(shipping_method)
    invs = []
    return invs unless validate_shipping_methods
    invs = @order.inventories.select do |inv|
      if shipping_method.class == ShippingMethod
        inv.shipping_method == shipping_method
      else
        inv.shipping_method.variety == shipping_method
      end
    end
  end

  def get_products(shipping_method)
    products = []
    return products unless validate_shipping_methods
    invs = get_inventories(shipping_method)
    invs.each { |inv| products << inv.product }
    products.uniq
  end

  def set_address(address_id)
    origin_address = Address.find(address_id)
    origin_address.copy_to(@order)
  end

  def confirm_shipping
    case @order.shipping_method_mix
    when 'self_pickup'
      validate_shipping_methods
      @order.shipping_confirmed!
    else
      validate_shipping_methods
      return false unless @order.address
      @order.shipping_confirmed!
    end
  end

  def compatible_shipping_rate(shipping_method)
    @order.address.geo_codes.each do |addr_code|
      shipping_method.shipping_rates.each do |rate|
        return rate if rate.geo_code == addr_code
      end
    end
    false
  end

  def billable_weight(shipping_method)
    invs = get_inventories(shipping_method)
    invs.sum { |inv| inv.product.weight }
  end

  def calculate_shipping(shipping_method)
    case shipping_method.variety
    when 'delivery' then delivery_cost(shipping_method)
    when 'self_pickup' then pickup_cost(shipping_method)
    when 'no_shipping' then Money.new(0)
    end
  end

  def delivery_cost(shipping_method)
    weight = billable_weight(shipping_method)
    add_on_weight = weight - 1 > 0 ? weight - 1 : 0
    rate = compatible_shipping_rate(shipping_method)
    cost = rate.init_rate
    cost += rate.add_on_rate * add_on_weight
  end

  def pickup_cost(shipping_method)
    rates = shipping_method.shipping_rates
    rate = rates.where(geo_code: '*').first || rates.first
    rate.init_rate + rate.add_on_rate
  end

  def total_shipping_cost
    @order.shipping_methods.sum { |m| calculate_shipping(m) }
  end

  def total_inventories_cost
    @order.inventories.sum { |i| i.purchase_price }
  end

  def confirm
    begin
      Order.transaction do
        confirm_shipping_cost
        confirm_inventories
        @order.confirmed!
      end
    rescue Exception
      false
    end
  end

  def staff_confirm
    return false unless @order.payment_success?
    @order.staff_confirmed!
  end

  def set_pickup_ready
    return false unless @order.shipping_methods.self_pickup.present?
    @order.update(shipment: {}) unless @order.shipment
    @order.shipment[:pickup_readied_at] = DateTime.now
    @order.pickup_pending! unless @order.shipped?
    @order.save
  end

  def add_tracking(params)
    return false unless @order.shipping_methods.delivery.present?
    @order.update(shipment: {}) unless @order.shipment
    @order.shipment[:shipping_company] = params[:shipping_company]
    @order.shipment[:tracking_number] = params[:tracking_number]
    @order.shipment[:shipped_at] = DateTime.now
    @order.shipped!
  end

  def complete_pickup
    return false unless @order.shipment['pickup_readied_at'].present?
    @order.shipment[:pickup_completed_at] = DateTime.now
    @order.save
    complete
  end

  def complete_shipping
    return false unless @order.shipment['shipped_at'].present?
    @order.shipment[:shipping_completed_at] = DateTime.now
    @order.save
    complete
  end

  private

    def set_shipping_method(product, shipping_method)
      @order.inventories_by(product).each do |inv|
        inv.update(shipping_method: shipping_method)
      end
    end

    def validate_shipping_methods
      @order.inventories.each do |inv|
        return false unless inv.try(:shipping_method).try(:variety)
      end
    end

    def confirm_inventories
      @order.inventories.each do |inv|
        inv.update(status: 3, purchase_price: inv.product.price_member,
                              purchase_weight: inv.product.weight)
      end
    end

    def confirm_shipping_cost
      raise unless validate_shipping_methods
      cost = total_shipping_cost
      @order.update(shipping_cost: cost)
    end

    def complete
      # set_complete = true
      # if @order.shipping_methods.self_pickup.present?
      #   set_complete = false unless @order.shipment['pickup_completed_at'].present?
      # end
      # if @order.shipping_methods.delivery.present?
      #   set_complete = false unless @order.shipment['shipping_completed_at'].present?
      # end
      # @order.completed! if set_complete
    end
end
