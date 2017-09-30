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
      flash.now[:warning] = "Please enter one or more search terms."
      render :search
    end
  end

  def show; end

  def confirm
    if @order_service.staff_confirm
      flash[:success] = "The order status is now #{@order.reload.status.titleize}."
    else
      flash[:danger] = "Unable to confirm this order."
    end
    redirect_to admin_order_path(@order)
  end

  def set_pickup_ready
    if @order_service.set_pickup_ready
      flash[:success] = "The order is now marked as ready for pickup"
    else
      flash[:danger] = "Unable to mark order as pickup ready."
    end
    redirect_to admin_order_path(@order)
  end

  def add_tracking
    unless params['shipping_company'].present? || params['pre_select_shipco'].nil?
      params['shipping_company'] = params['pre_select_shipco']
    end

    if params['tracking_number'].present? && params['shipping_company'].present?
      if @order_service.add_tracking(params)
        flash[:success] = "Successfully added tracking information to order."
      else
        flash[:danger] = 'Unable to save tracking information to order. Please
                          double check the value provided.'
      end
    else
      flash[:warning] = 'Please provide or select and shipping company and
                         enter the tracking number.'
    end
    redirect_to admin_order_path(@order)
  end

  def complete_pickup
    @order_service.complete_pickup
    flash[:success] = "Completed self pickup. Order status is
                       now #{@order.status.titleize}"
    redirect_to admin_order_path(@order)
  end


  private

    def set_order
      @order = Order.find(params[:id])
      @order_service = OrderService.new(order_id: @order.id)
    end

end
