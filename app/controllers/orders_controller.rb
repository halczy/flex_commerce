class OrdersController < UsersController
  # Filters
  before_action :friendly_signin, only: [ :create ]
  before_action :authenticate_user, except: [ :create ]
  before_action :set_user, except: [ :create ]
  before_action :set_order, except: [ :index, :create, :update_selector ]
  before_action :populate_selector, only: [ :address, :update_selector ]
  before_action :set_payment_amount, only: [ :wallet_payment ]
  before_action :set_payment, only: [ :success, :failure ]

  def index
    filter = params[:filter] || ""
    orders = Order.try(filter, @user) || Order.service_process(@user)
    orders = orders.order(updated_at: :desc)
    @orders = orders.page params[:page]
  end

  def show
    @self_pickup = helpers.get_self_pickup_method(@order)
    @delivery = helpers.get_delivery_method(@order)
    @transactions = @order.transactions.select { |t| t.originable.charge? }
  end

  def create
    order = OrderService.new(cart_id: params[:cart_id]).create
    if order
      redirect_to shipping_order_path(order)
    else
      flash[:danger] = t('.danger')
      redirect_to cart_path
    end
  end

  def shipping; end

  def set_shipping
    product_params = params['order']['products_attributes'] if params['order']
    if @order_service.set_shipping(product_params)
      if @order.shipping_method_mix == 'no_shipping'
        redirect_to review_order_path(@order)
      else
        redirect_to address_order_path(@order)
      end
    else
      redirect_to shipping_order_path(@order)
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
    elsif params[:address][:address_id].present?
      set_address
    else
      @self_pickups = @order_service.get_products('self_pickup')
      @deliveries = @order_service.get_products('delivery')
      @customer = @order.user
      set_address_params
      populate_selector
      flash.now[:warning] = t('.warning')
      render :address
    end
  end

  def set_address
    if params[:address] && params[:address][:address_id]
      @order_service.set_address(params[:address][:address_id])
      @order_service.confirm_shipping
    else
      @order_service.confirm_shipping
    end
    redirect_to review_order_path
  end

  def review
    @self_pickup = helpers.get_self_pickup_method(@order)
    @delivery = helpers.get_delivery_method(@order)
  end

  def confirm
    if @order_service.confirm
      redirect_to payment_order_path
    else
      flash[:warning] = t('.warning')
      redirect_to review_order_path
    end
  end

  def payment;end

  def wallet_payment
    charge_result = pay_via_wallet

    if @order.reload.payment_success?
      redirect_to success_order_path(id: @order.id, payment_id: @payment.id)
    elsif charge_result && @order.reload.partial_payment?
      flash[:success] = t('.success')
      redirect_to payment_order_path
    end
  end

  def alipay_payment
    payment_service = PaymentService.new(order_id: @order.id, processor: 'alipay')
    if payment_service.create
      redirect_to payment_service.charge
    else
      flash[:warning] = t('.warning')
      redirect_to payment_order_path
    end
  end

  def success; end

  def resume
    case @order.status_before_type_cast
    when 0      then redirect_to(shipping_order_path(@order))
    when 10     then redirect_to(review_order_path(@order))
    when 20..50 then redirect_to(payment_order_path(@order))
    end
  end

  def destroy
    if @order.cancel
      flash[:success] = t('.success')
      redirect_to orders_path
    else
      flash[:danger] = t('.danger')
      redirect_to @order
    end
  end

  private

    def set_order
      @order = Order.find(params[:id])
      @order_service = OrderService.new(order_id: @order.id)
      validate_access
    end

    def friendly_signin
      unless helpers.signed_in?
        helpers.store_return_url
        redirect_to signin_path
      end
    end

    def populate_selector
      @provinces = Geo.province_state
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

    def confirm_order
      @order_service.confirm
    end

    def set_address_params
      params[:province_id] = @address.province_state if @address.province_state.present?
      params[:city_id] = @address.city if @address.city.present?
      params[:district_id] = @address.district if @address.district.present?
      params[:community_id] = @address.community if @address.community.present?
    end

    def validate_access
      unless helpers.current_user?(@order.user) || helpers.current_user.admin?
        flash[:danger] = t('orders.validate_access.danger')
        redirect_to root_url
      end
    end

    def set_payment_amount
      validity = true
      validity = false if helpers.current_user.wallet.available_fund == 0
      validity = false unless params[:amount].present? || params[:custom_amount].present?

      if params[:amount].present? && params[:custom_amount].blank?
        @amount = params[:amount].to_money
      elsif params[:custom_amount].present?
        @amount = params[:custom_amount].to_money
      end

      validity = false if @amount == 0
      validity = false if @amount > helpers.current_user.wallet.available_fund
      validity = false unless @amount.between?(0.01.to_money, @order.amount_unpaid)

      unless validity && @amount
        flash[:warning] = t('orders.set_payment_amount.warning')
        redirect_to payment_order_path and return
      end
    end

    def pay_via_wallet
      payment_service = PaymentService.new(
        order_id: @order.id, amount: @amount, processor: 'wallet'
      )
      @payment = payment_service.create
      if @payment
        payment_service.charge
      else
        flash[:danger] = t('orders.pay_via_wallet.danger')
        redirect_to payment_order_path and return
      end
    end

    def set_payment
      @payment = Payment.find(params[:payment_id])
    end
end
