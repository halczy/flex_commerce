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

  # GROUP ORDER INVENTORIES BY SHIPPING METHODS
    # GET SHIPPING METHODS FROM ORDER
      # LOOP THROUGH EACH DELIVERY METHOD FOR SHIPPING COST
      # LOOP THROUGH EACH SELF PICKUP METHOD FOR SHIPPING COST

  # DELIVERY - SHIPPING COST
    # INVENTORIES - GET BILLABLE WEIGHT
    # FIND COMPATABLE SHIPPING RATE
    # CALCULATE SHIPPING COST FOR THE METHOD

  # SELF PICKUP
    # GET SHIPPING RATE WITH * MATCHER
    # USE INIT RATE AS SHIPPING COST

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

  # def billable_weight
  #   weight = 0
  #   @order.inventories.each do |inv|
  #     weight += inv.product.weight if inv.shipping_method.variety == 'delivery'
  #   end
  #   weight
  # end

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
