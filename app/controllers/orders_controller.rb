class OrdersController < UsersController
  # Filters
  before_action :request_signin, only: [ :create ]
  before_action :authenticate_user, except: [ :create ]
  before_action :set_user, except: [ :create ]
  before_action :set_order, only: [ :shipping, :set_shipping, :create_address, :address, :payment ]
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
    product_params = params['order']['products_attributes'] if params['order']
    if @order_service.set_shipping(product_params)
      redirect_to address_order_path(@order)
    else
      redirect_to set_shipping_order_path(@order)
    end
  end

  def address
    @self_pickups = @order_service.get_products('self_pickup')
    @deliveries = @order_service.get_products('delivery')
    @customer = @order.user
    @address = Address.new
  end

  def update_selector
    respond_to do |format|
      format.js
    end
  end

  def create_address
    @address = @user.addresses.new(address_params)
    if @address.save
      @address.build_full_address
      params[:address][:address_id] = @address.id
      set_address
    else
      set_order
      @self_pickups = @order_service.get_products('self_pickup')
      @deliveries = @order_service.get_products('delivery')
      @customer = @order.user
      populate_selector
      render :address
    end
  end

  def set_address
  end

  def payment
  end

  private

    def set_order
      @order = Order.find(params[:id])
      @order_service = OrderService.new(order_id: @order.id)
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

    def address_params
      params.require(:address).permit(:name, :recipient, :contact_number,
                                      :country_region, :province_state,
                                      :city, :district, :community, :street)
    end
end
