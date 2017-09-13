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

  def get_products(shipping_method)
    products = []
    return products unless validate_shipping_methods
    invs = @order.inventories.select do |inv|
      inv.shipping_method.variety == shipping_method
    end
    invs.each { |inv| products << inv.product }
    products.uniq
  end

  private

    def set_shipping_method(product, shipping_method)
      @order.quantity(product).each do |inv|
        inv.update(shipping_method: shipping_method)
      end
    end

    def validate_shipping_methods
      @order.inventories.each do |inv|
        return false unless inv.shipping_method.variety
      end
    end

end
