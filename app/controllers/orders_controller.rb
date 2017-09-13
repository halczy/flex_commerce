class OrdersController < UsersController
  # Filters
  before_action :request_signin, only: [ :create ]
  before_action :authenticate_user, except: [ :create ]
  # before_action :set_order, except: [ :create, :index, :populate_selector, :update_selector ]
  before_action :set_order, only: [ :shipping, :set_shipping, :address ]
  before_action :populate_selector, only: [:address, :update_selector]

  def create
    order = OrderService.new(cart_id: params[:cart_id]).create
    if order
      redirect_to shipping_order_path(order)
    else
      flash[:danger] = 'Unable to create order.'
      redirect_to cart_path
    end
  end

  def shipping; end

  def set_shipping
    order = OrderService.new(order_id: @order.id)
    product_params = params['order']['products_attributes'] if params['order']
    if order.set_shipping(product_params)
      redirect_to address_order_path(@order)
    else
      redirect_to set_shipping_order_path(@order)
    end
  end

  def address
    order = OrderService.new(order_id: @order.id)
    @self_pickups = order.get_products('self_pickup')
    @deliveries = order.get_products('delivery')
    @customer = @order.user
    @address = Address.new
  end

  def update_selector
    respond_to do |format|
      format.js
    end
  end

  def set_address
    raise
  end

  private

    def set_order
      @order = Order.find(params[:id])
    end

    def request_signin
      unless helpers.signed_in?
        helpers.store_return_url
        redirect_to signin_path
      end
    end

    def populate_selector
      @provinces = Geo.cn.children
      @province = Geo.find_by(id: params[:province_id])

      @cities = @province.try(:children) || []
      @city = Geo.find_by(id: params[:city_id])

      @districts = @city.try(:children) || []
      @district = Geo.find_by(id: params[:district_id])

      @communities = @district.try(:children) || []
      @community = Geo.find_by(id: params[:community_id])
    end
end
