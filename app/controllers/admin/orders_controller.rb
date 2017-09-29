class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [ :show, :confirm ]

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

  def confirm
    if @order_service.staff_confirm
      flash[:success] = "The order status is now #{@order.reload.status.titleize}."
    else
      flash[:danger] = "Unable to confirm this order."
    end
    redirect_to admin_order_path(@orderer)
  end

  def show; end

  private

    def set_order
      @order = Order.find(params[:id])
      @order_service = OrderService.new(order_id: @order.id)
    end

end
