class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [ :show ]

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

  private

    def set_order
      @order = Order.find(params[:id])
    end

end
