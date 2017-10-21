class Admin::OrdersController < Admin::AdminController
  before_action :set_order, except: [ :index, :search ]

  def index
    status = params[:status] ||= ""
    orders = Order.try(status) || Order.all
    orders = orders.order(updated_at: :desc)
    @orders = orders.page params[:page]
  end

  def search
    search_term = params[:search_term] || ""
    unless search_term.empty?
      @search_run = OrderSearchService.new(search_term).search
      @search_result = Kaminari.paginate_array(@search_run).page(params[:page])
    else
      flash.now[:warning] = t('.warning')
      render :search
    end
  end

  def show
    @self_pickup = helpers.get_self_pickup_method(@order)
    @delivery = helpers.get_delivery_method(@order)
  end

  def confirm
    if @order_service.staff_confirm
      flash[:success] = t('.success', status: @order.translated_status)
    else
      flash[:danger] = t('.danger')
    end
    redirect_to admin_order_path(@order)
  end

  def set_pickup_ready
    if @order_service.set_pickup_ready
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.danger')
    end
    redirect_to admin_order_path(@order)
  end

  def add_tracking
    unless params['shipping_company'].present? || params['pre_select_shipco'].nil?
      params['shipping_company'] = params['pre_select_shipco']
    end

    if params['tracking_number'].present? && params['shipping_company'].present?
      if @order_service.add_tracking(params)
        flash[:success] = t('.success')
      else
        flash[:danger] = t('.danger')
      end
    else
      flash[:warning] = t('.warning')
    end
    redirect_to admin_order_path(@order)
  end

  def complete_pickup
    @order_service.complete_pickup
    flash[:success] = t('.success')
    redirect_to admin_order_path(@order)
  end

  def complete_shipping
    @order_service.complete_shipping
    flash[:success] = t('.success')
    redirect_to admin_order_path(@order)
  end

  private

    def set_order
      @order = Order.find(params[:id])
      @order_service = OrderService.new(order_id: @order.id)
    end
end
