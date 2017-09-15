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
    rescue Exception => e
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
    cost = @order.shipping_methods.sum { |m| calculate_shipping(m) }
    cost.tap { |cost| @order.update(shipping_cost: cost) }
  end

  private

    def set_shipping_method(product, shipping_method)
      @order.quantity(product).each do |inv|
        inv.update(shipping_method: shipping_method)
      end
    end

    def validate_shipping_methods
      @order.inventories.each do |inv|
        return false unless inv.try(:shipping_method).try(:variety)
      end
    end

end
